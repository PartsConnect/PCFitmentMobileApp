using Dapper;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using TestRestAPI.Models.Utilities;

namespace PartsConnectWebTools.Helpers
{
    public class ValidateExcelHelper
    {
        static string myConnectionString = clsConnection.CommonConnString();
        public static bool CheckIsMultiBrandAccess(int tenantID)
        {
            bool is_multi = false;
            DataTable dtmulti = new DataTable();
            //string Query = "SELECT * FROM tools.Tenants WHERE ID = " + tenantID + " AND ISNULL(IsMultiBrandAccess,0)= 1 ";
            string Query = "SELECT * FROM tools.Tenants WHERE ID = " + tenantID + " AND ISNULL(BrandLimit,0) > 1 ";
            using (var conn = new SqlConnection(myConnectionString))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.Fill(dtmulti);
            }
            if (dtmulti != null && dtmulti.Rows.Count > 0)
            {
                is_multi = true;
            }
            return is_multi;
        }
        public static DataTable GetBrandDetail(int tenantID, string BrandCode = "")
        {
            DataTable dt = new DataTable();
            string Query = "SELECT BrandCode, BrandName FROM tools.Brand WHERE tenantID = " + tenantID + " AND ISNULL(IsDeleted,0) = 0 ";
            if (!string.IsNullOrWhiteSpace(BrandCode))
            {
                Query = Query + " AND ISNULL(BrandCode,'') = '" + BrandCode + "'";
            }
            using (var conn = new SqlConnection(myConnectionString))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.Fill(dt);
            }
            return dt;
        }
        public static string GetLastAddedFileUserInfo(int tenantID)
        {
            string status = "", response = "", newFitments = "", newParts = "";
            DataTable dtfitment = GetLasstUploadedFileDetails(tenantID);
            if (dtfitment != null && dtfitment.Rows.Count > 0)
            {
                status = string.IsNullOrWhiteSpace(dtfitment.Rows[0]["status"].ToString()) ? "" : dtfitment.Rows[0]["status"].ToString();
            }
            if (status == "D")
            {
                newFitments = string.IsNullOrWhiteSpace(dtfitment.Rows[0]["NewFitmentCount"].ToString()) ? "0" : dtfitment.Rows[0]["NewFitmentCount"].ToString();
                newParts = string.IsNullOrWhiteSpace(dtfitment.Rows[0]["NewPartCount"].ToString()) ? "0" : dtfitment.Rows[0]["NewPartCount"].ToString();

                response = "Completed|" + newFitments + "|" + newParts;

            }
            else if (status == "E")
            {
                response = "Error";
            }
            else if (status == "F")
            {
                response = "FileError";
            }
            else
            {
                response = "";
            }
            return response;
        }
        public static DataTable GetLasstUploadedFileDetails(int tenantID)
        {
            DataTable dtfitment = new DataTable();
            string Query = @" SELECT * FROM tools.AddFitmentRequest WHERE userfileid = (SELECT TOP(1) userfilesid FROM tools.userfiles WHERE ISNULL(validationtype,'Advance') = 'Advance' AND userid = @userid ORDER BY userfilesid DESC) AND tenantID =  @userid ";
            using (var conn = new SqlConnection(myConnectionString))
            {
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.SelectCommand.Parameters.AddWithValue(@"userid", tenantID);
                da.Fill(dtfitment);
            }
            return dtfitment;
        }
        public static dynamic GetLastuploadinfooftheUser(int userfilesid, int tenantID)
        {
            dynamic data;
            string Query = @" SELECT * FROM tools.userfiles WHERE ISNULL(validationtype,'Advance') = 'Advance' AND userid=@userid and userfilesid = @userfilesid ORDER BY userfilesid DESC ";
            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                data = conn.Query<dynamic>(Query, new { userid = tenantID, userfilesid = userfilesid });
                conn.Close();
            }
            return data;
        }
        public static void InsertRecordsAddFitmentRequest(int TenantID, dynamic FilePath, dynamic UserFilesID)
        {
            string Query = @" UPDATE tools.userfiles SET flagAddFitment =1  WHERE ISNULL(validationtype,'Advance') = 'Advance' AND userid=@tenantID AND userfilesid=@userfileid; 
                INSERT INTO tools.AddFitmentRequest (tenantID, filepath, createddate, createdby, status, userfileid) VALUES (@tenantID, @filepath, @createddate, @createdby, @status, @userfileid);";

            using (var conn = new SqlConnection(myConnectionString))
            {
                conn.Open();
                conn.Query(Query, new { tenantID = TenantID, filePath = FilePath, createddate = DateTime.Now, createdby = TenantID, status = "P", userfileid = UserFilesID });
                conn.Close();
            }
        }

    }
}