using Dapper;
using PartsConnectWebTools.Data;
using PartsConnectWebTools.Models.Custom;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Web;
using TestRestAPI.Models.Utilities;

namespace PartsConnectWebTools.Helpers
{
    public static class AmazonHelper
    {
        private static string myConnectionString = clsConnection.CommonConnString();
        public static TenantsHeaderDetail GetHeaderDetails(int tenantID)
        {
            TenantsHeaderDetail header = new TenantsHeaderDetail();
            string Query = @"SELECT * FROM tools.TenantsHeaderDetail WHERE TenantID=@TenantID ;";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                header = conn.Query<TenantsHeaderDetail>(Query, new { TenantID = tenantID }).FirstOrDefault();
                conn.Close();
            }
            Brand brand = new Brand();
            Query = @" SELECT *, CASE WHEN ISNULL(IsBrandVerified,0) = 1 THEN 'Yes' ELSE 'No' END AS 'IsBrandVerifiedtxt'
                        FROM tools.Brand WHERE TenantID = @TenantID  AND ISNULL(IsDeleted,0) = 0 ";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                brand = conn.Query<Brand>(Query, new { TenantID = tenantID }).FirstOrDefault();
                conn.Close();
            }
            if (header != null)
            {
                if (brand != null)
                {
                    header.brandaaiaid = brand.BrandCode;
                    header.IsBrandVerifiedtxt = brand.IsBrandVerifiedtxt;
                    header.BrandName = brand.BrandName + " (" + brand.BrandCode + ")";
                }
            }
            else
            {
                if (brand != null)
                {
                    header = new TenantsHeaderDetail();
                    header.brandaaiaid = brand.BrandCode;
                    header.company = brand.Company;
                    header.senderphone = brand.Phone;
                }
            }
            return header;
        }
        public static bool CheckUserFitmentsTable(int tenantID)
        {
            bool IsExist = false;
            string FitmentTable = "FitmentsSaved_" + tenantID;
            string UniversalTable = "UniversalCollection_" + tenantID;
            //string Query = @"SELECT COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + FitmentTable + @"' AND TABLE_SCHEMA = 'tools';";

            string Query = @"SELECT COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  (TABLE_NAME = '" + FitmentTable + @"' OR TABLE_NAME = '" + UniversalTable + @"') AND TABLE_SCHEMA = 'tools';";

            int Count = 0;
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                Count = conn.Query<int>(Query).FirstOrDefault();
                conn.Close();
            }
            if (Count > 0)
            {
                IsExist = true;
            }
            else
            {
                IsExist = false;
            }
            return IsExist;
        }
        public static DataTable GetTodayReq(int tenantID)
        {

            string Query = @"SELECT * FROM tools.ExportRequest WHERE TenantID = " + tenantID + @" AND RequestCode = 'AMAZON' AND CAST([CreatedDate] AS DATE) =  CAST(GETDATE() AS DATE) ";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(myConnectionString))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.Fill(dt);
            }

            return dt;
        }
        public static bool IsFitmentsAvailableToSubmit(int tenantID, string BrandID)
        {
            bool IsAvailable = false;
            string flagTablename = "FitmentsSaved_" + tenantID;
            string tablename = "tools.FitmentsSaved_" + tenantID;
            string PartTable = "tools.Parts_" + tenantID;
            string brand_condition = "";
            if (!string.IsNullOrWhiteSpace(BrandID))
            {
                brand_condition = " AND PartID IN( SELECT id FROM " + PartTable + " WHERE BrandID = '" + BrandID + "')";
            }
            string Query = "";
            Query = @" DECLARE @flag1 INT  SELECT @flag1 = COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagTablename + @"' AND TABLE_SCHEMA = 'tools';  

           IF ISNULL(@flag1,0)<> 0
               BEGIN
                 SELECT COUNT(id) AS fitmentCount FROM  " + tablename + @" WHERE TenantID=" + tenantID + @"  AND ISNULL(isinvalid,0)=0 
                 AND ISNULL(isAmazonSubmited,0)=0 AND VehicleTypeID IN(5, 6, 7, 44, 46, 47, 48, 49, 50, 2189) " + brand_condition + @" 
               END";
            SqlDataAdapter da = new SqlDataAdapter();
            DataTable dt = new DataTable();
            // DBName VersionDate	CreatedDate
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                da = new SqlDataAdapter(Query, conn);
                da.Fill(dt);
                conn.Close();
            }
            int fitmentCount = 0;
            if (dt != null && dt.Rows.Count > 0)
            {
                fitmentCount = Convert.ToInt32(dt.Rows[0]["fitmentCount"].ToString());
            }
            if (fitmentCount > 0)
            {
                IsAvailable = true;
            }

            if (!IsAvailable)
            {
                bool IsCollection = false;
                string Query2 = @"IF EXISTS (SELECT * FROM   INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = 'UniversalCollection_" + tenantID + @"'AND TABLE_SCHEMA = 'tools')
                    SELECT 1 AS res ELSE SELECT 0 AS res ";

                using (var conn = new SqlConnection(myConnectionString))
                {
                    conn.Open();
                    IsCollection = Convert.ToBoolean(conn.Query<bool>(Query2).FirstOrDefault());
                    conn.Close();
                }
                if (IsCollection)
                {
                    PartsHelper.AddUniversalCollectionColumns(tenantID);
                    string Query1 = "";
                    Query1 = @" SELECT * FROM " + PartTable + @" WHERE ISNULL(collectionId,0) > 0 
                            AND ISNULL(InitialSubmission,0) = 0 
                            AND BrandID = '" + BrandID + "'";
                    DataTable dtCollection = new DataTable();
                    using (var conn = new SqlConnection(myConnectionString))
                    {
                        conn.Open();
                        da = new SqlDataAdapter(Query1, conn);
                        da.Fill(dtCollection);
                        conn.Close();
                    }
                    if (dtCollection != null && dtCollection.Rows.Count > 0)
                    {
                        IsAvailable = true;
                    }
                }
            }

            return IsAvailable;
        }
        public static bool CheckPendingReq(int tenantID, string brand)
        {
            DataTable dt = new DataTable();
            bool status = false;
            string Query = "Select * from [tools].[ExportRequest] where status='p' and RequestCode = 'AMAZON' AND TenantID=" + tenantID + " AND BrandID = '" + brand + "'";
            using (var conn = new SqlConnection(myConnectionString))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.Fill(dt);
            }
            if (dt != null && dt.Rows.Count > 0)
            {
                status = true;
            }
            return status;
        }
        public static void SaveUserDownloadedData(int tenanatID, string RequestCode, string brandID = "", bool IsExpiredUser = false)
        {
            string Query = @"insert into tools.ExportRequest (TenantID,RequestCode,CreatedDate,status, BrandID,IsExpiredUser) values(@TenantID,@RequestCode,@CreatedDate,@status, @brandid,@isexpireduser)";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                conn.Query(Query, new { TenantID = tenanatID, RequestCode = RequestCode, CreatedDate = DateTime.Now, status = "p", brandid = brandID, isexpireduser = IsExpiredUser });
                conn.Close();
            }
        }
        public static bool CheckPendingReqVerifyAmazon(int tenantID, string brand)
        {
            DataTable dt = new DataTable();
            bool status = false;
            string Query = "SELECT * FROM [tools].[BrandVerification] WHERE status='p' and RequestCode = 'AMAZON' AND TenantID=" + tenantID + " AND BrandID = '" + brand + "'";

            using (var conn = new SqlConnection(myConnectionString))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.Fill(dt);
            }
            if (dt != null && dt.Rows.Count > 0)
            {
                status = true;
            }
            return status;
        }
        public static bool IsBrandExists(int tenantID, string brand)
        {
            DataTable dt = new DataTable();
            bool status = false;
            string Query = "SELECT * FROM [tools].[BrandVerification] WHERE RequestCode = 'AMAZON' AND TenantID=" + tenantID + " AND BrandID = '" + brand + "'";

            using (var conn = new SqlConnection(myConnectionString))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.Fill(dt);
            }
            if (dt != null && dt.Rows.Count > 0)
            {
                status = true;
            }
            return status;
        }
        public static int CheckHoursDifference(int tenantID, string brand)
        {
            DataTable dt = new DataTable();
            int HoursDiff = 0;
            string Query = "SELECT DATEDIFF(hour, CreatedDate, GETDATE()) AS HoursDiff FROM [tools].[BrandVerification] WHERE RequestCode = 'AMAZON' AND TenantID = " + tenantID + " AND BrandID = '" + brand + "'";

            using (var conn = new SqlConnection(myConnectionString))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.Fill(dt);
            }
            if (dt != null && dt.Rows.Count > 0)
            {
                HoursDiff = Convert.ToInt32(dt.Rows[0]["HoursDiff"]);
            }
            return HoursDiff;
        }
        public static void SaveUserDownloadedDataBrand(int tenanatID, string RequestCode, string brandID = "", bool IsExpiredUser = false)
        {
            string Query = @"insert into tools.BrandVerification (TenantID,RequestCode,CreatedDate,status, BrandID) values(@TenantID,@RequestCode,@CreatedDate,@status, @brandid)";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                conn.Query(Query, new { TenantID = tenanatID, RequestCode = RequestCode, CreatedDate = DateTime.Now, status = "p", brandid = brandID });
                conn.Close();
            }
        }
        public static bool GetEbayloginpendingRequst(int ebayloginreqtype)
        {
            bool isreeq = false;
            List<eBayLoginReq> reqlist = new List<eBayLoginReq>();
            string Query = @" SELECT * FROM tools.eBayLoginRequest WHERE reqstatus = 'P'  AND DATEADD(mi, " + ebayloginreqtype + @", reqDate)>= GETDATE() ";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                reqlist = conn.Query<eBayLoginReq>(Query).ToList();
                conn.Close();
            }
            if (reqlist.Count > 0)
            {
                isreeq = true;
            }
            return isreeq;
        }
        public static string CheckEbayPendingRequest(int tenantID)
        {
            DataTable dtreq = new DataTable();
            dtreq = GetEbayPendingRequest(tenantID);
            string status = "";

            if (dtreq.Rows.Count > 0)
            {
                status = dtreq.Rows[0]["ReqType"].ToString();
            }
            return status;
        }
        public static DataTable GetEbayPendingRequest(int tenantID)
        {
            string Query = @"SELECT * FROM tools.EbayRequest WHERE status = 'P' AND TenantID = @TenantID ;";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.SelectCommand.Parameters.AddWithValue("@TenantID", tenantID);
                da.Fill(dt);
                conn.Close();
            }
            return dt;
        }
        public static string CheckeBaySubmitError(int tenantID)
        {
            string ErrorMsg = "";
            string Query = @"SELECT TOP 1 errortext,status FROM tools.EbayRequest WHERE TenantID = " + tenantID + " ORDER BY ID DESC ";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(myConnectionString))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.Fill(dt);
            }
            if (dt != null && dt.Rows.Count > 0)
            {
                if (dt.Rows[0]["status"].ToString() == "E")
                {
                    string appname = "PCFitment";
                    string fitmentsite = commonMethods.Getappname();
                    string afitmenturl = commonMethods.Getafitmenturl();
                    //string currneturl = location.AbsoluteUri;
                    //if (currneturl.Contains(afitmenturl))
                    //{
                    //    appname = fitmentsite;
                    //}
                    string Error = dt.Rows[0]["errortext"].ToString();
                    string err = commonMethods.GeteBayErrorMsg();
                    if (Error.Contains(err))
                    {
                        ErrorMsg = "We have get below error while submitting your fitments on eBay." + "<br/>" + "You have not authenticate PCFitment to update fitments on your store. Please contact us at support@partsconnect.us for more information.".Replace("PCFitment", appname) + "";
                    }
                }

            }
            return ErrorMsg;
        }

        public static string MakeRequestForEbay(string reqType, int tenantID)
        {
            string res = "";
            string Query = @"INSERT INTO tools.eBayRequest (TenantID, SubmittedDate, status, ECat, ReqType) VALUES(@tenantid, @curdate, @status, @catalog, @req)";
            try
            {
                using (var conn = new SqlConnection(myConnectionString))
                {
                    conn.Open();
                    conn.Query(Query, new { tenantid = tenantID, curdate = DateTime.Now, status = "P", catalog = "Ebay", req = reqType }).ToList();
                    conn.Close();
                }
                res = "Done";
            }
            catch (Exception ex)
            {
                res = ex.Message.ToString();
            }
            return res;

        }

    }
}