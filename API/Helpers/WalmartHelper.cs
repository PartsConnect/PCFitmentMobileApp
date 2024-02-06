using Dapper;
using PartsConnectWebTools.Data;
using PartsConnectWebTools.Models.Custom;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using System.Globalization;
using System.Linq;
using System.Web;
using TestRestAPI.Models.Utilities;

namespace PartsConnectWebTools.Helpers
{
    public static class WalmartHelper
    {
        private static string myConnectionString = clsConnection.CommonConnString();
        public static TenantsHeaderDetail GetHeaderDetails(int tenantID)
        {
            TenantsHeaderDetail header = new TenantsHeaderDetail();
            string Query = @"SELECT *,
                                CASE WHEN IsWalmartAccess = 1 AND IsWalmartSetupDone = 1
                                	 THEN 'Yes' ELSE 'No' END AS IsWalmartLogin
                                FROM 
                                tools.TenantsHeaderDetail THD
                                INNER JOIN tools.tenants TD
                                ON TD.ID = THD.TenantID
                                WHERE THD.TenantID = @TenantID;";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                header = conn.Query<TenantsHeaderDetail>(Query, new { TenantID = tenantID }).FirstOrDefault();
                conn.Close();
            }
            Brand brand = new Brand();
            Query = @" SELECT *, CASE WHEN ISNULL(IsBrandVerified,0) = 1 THEN 'Yes' ELSE 'No' END AS 'IsBrandVerifiedtxt' FROM tools.Brand WHERE TenantID = @TenantID  AND ISNULL(IsDeleted,0) = 0 ";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                brand = conn.Query<Brand>(Query, new { TenantID = tenantID }).FirstOrDefault();
                conn.Close();
            }
            if (header != null)
            {
                header.brandaaiaid = brand.BrandCode;
                header.IsBrandVerifiedtxt = brand.IsBrandVerifiedtxt;
                header.BrandName = brand.BrandName + " (" + brand.BrandCode + ")";
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
            string FitmentTable = "FitmentsSaved_" + tenantID;
            string Query = @"SELECT COUNT(*)FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + FitmentTable + @"' AND TABLE_SCHEMA = 'tools';";
            int Count = 0;
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                Count = conn.Query<int>(Query).FirstOrDefault();
                conn.Close();
            }
            if (Count > 0)
            {
                return true;
            }
            else
            {
                return false;
            }

        }
        public static bool IsFitmentsAvailableToSubmit(int tenantID)
        {
            bool IsAvailable = false;
            string flagTablename = "FitmentsSaved_" + tenantID;
            string tablename = "tools.FitmentsSaved_" + tenantID;
            string PartTable = "tools.Parts_" + tenantID;
            string Query = "";
            Query = @" DECLARE @flag1 INT  SELECT @flag1 = COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE  TABLE_NAME = '" + flagTablename + @"' AND TABLE_SCHEMA = 'tools';  

           IF ISNULL(@flag1,0)<> 0
               BEGIN
                 SELECT COUNT(id) AS fitmentCount FROM  " + tablename + @" WHERE TenantID=" + tenantID + @"  AND ISNULL(isinvalid,0)=0 
                 AND ISNULL(WalmartSubmitted,0)=0 AND ISNULL(IsDeleted,0)=0 AND ISNULL(Action,'')='A' 
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
            return IsAvailable;
        }
        public static void SaveUserDownloadedData(int tenanatID, string RequestCode, string brandID = "", bool IsExpiredUser = false)
        {
            string Query = @"insert into tools.ExportRequest (TenantID,RequestCode,CreatedDate,status, BrandID,IsExpiredUser, Ecat) values(@TenantID,@requestcode,@CreatedDate,@status, @brandid,@isexpireduser, @ecat)";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                conn.Query(Query, new { TenantID = tenanatID, requestcode = RequestCode, CreatedDate = DateTime.Now, status = "p", brandid = brandID, isexpireduser = IsExpiredUser, ecat = RequestCode });
                conn.Close();
            }
        }
        public static int GetTotalFitments(int tenantID)
        {
            string Query = "";
            int Count = 0;
            Query = CustomQueryBuillder.GetTotalFitmentWalmartQueryForExport(tenantID);

            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                SqlCommand cmd = new SqlCommand(Query, conn);
                string getValue = cmd.ExecuteScalar().ToString();
                if (getValue != null)
                {
                    Count = Convert.ToInt32(getValue.ToString());
                }
                conn.Close();
            }
            return Count;
        }
        public static bool ValidateButton(int tenantID, string RequestCode)
        {
            DataTable dt = new DataTable();
            bool status = false;
            string Query = "Select RequestCode from [tools].[ExportRequest] where status='p' and TenantID=" + tenantID;
            using (var conn = new SqlConnection(myConnectionString))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.Fill(dt);
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    if (dt.Rows[i]["RequestCode"].ToString() != "" || dt.Rows[i]["RequestCode"].ToString() != null)
                    {
                        if ((dt.Rows[i]["RequestCode"].Equals(RequestCode)))
                        {
                            status = true;
                            break;
                        }
                    }
                }

            }
            return status;
        }
        public static dynamic GetValidationTime(int tenantID)
        {
            string search = "";
            int time = 0;
            search = @"SELECT ISNULL(EstimatedTime,0) AS EstimatedTime  FROM tools.ReValidationReq WHERE ISNULL(IsVerified,0)=0 AND TenantID=@tenantid";
            using (var conn = new SqlConnection(myConnectionString))
            {
                DataTable dt = new DataTable();
                SqlDataAdapter da = new SqlDataAdapter(search, conn);
                da.SelectCommand.Parameters.AddWithValue("@tenantid", tenantID);
                da.Fill(dt);
                if (dt.Rows.Count > 0)
                {
                    time = Convert.ToInt32(dt.Rows[0]["EstimatedTime"].ToString());
                }
            }
            string ValidationTime = "";

            if (time > 60)
            {
                int h = time / 60;
                int m = time % 60;
                ValidationTime = h + " hr " + m + " min ";
            }
            else
            {
                ValidationTime = time + " min ";
            }
            return ValidationTime;
        }
        public static AmazonData GetUserSubmissionInfo(int tenantID, string requestCode)
        {
            AmazonData UserStatus = new AmazonData();
            DateTime CreatedDate = DateTime.Now;
            bool IsUserRequestPending = ValidateButton(tenantID, "WALMART");
            if (IsUserRequestPending)
            {
                string Query = "SELECT TOP 1 CreatedDate FROM tools.ExportRequest WHERE TenantID=@TenantID AND status='p' AND RequestCode=@RequestCode ORDER BY ID DESC";
                using (var conn = new SqlConnection(myConnectionString))
                {
                    conn.Open();
                    CreatedDate = conn.Query<DateTime>(Query, new { TenantID = tenantID, RequestCode = requestCode }).FirstOrDefault();
                    conn.Close();
                }
                UserStatus.SubmissionDate = CreatedDate;
                UserStatus.IsInProcess = true;

            }
            else
            {
                UserStatus = null;
            }
            return UserStatus;
        }
    }
}