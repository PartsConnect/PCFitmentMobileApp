using Dapper;
using PartsConnectWebTools.Data;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using PartsConnectWebTools.Models.Custom;
using System.Text;
using TestRestAPI.Models.Utilities;

namespace PartsConnectWebTools.Helpers
{
    public class BrandHelper
    {
        static string connString = clsConnection.CommonConnString();
        public static bool IsBrandVerified(string BrandID,int TenantID)
        {
            string Query = @" SELECT * FROM tools.Brand WHERE ISNULL(IsDeleted,0) = 0 AND ISNULL(IsBrandVerified,0) = 1 AND BrandCode = @BrandID AND  TenantID = @TenantID ";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlDataAdapter da = new SqlDataAdapter(Query, conn);
                da.SelectCommand.Parameters.AddWithValue("@BrandID", BrandID);
                da.SelectCommand.Parameters.AddWithValue("@TenantID", TenantID);
                da.Fill(dt);
                conn.Close();
            }

            if(dt != null && dt.Rows.Count> 0)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        public static List<Brand> GetAllBrands(int tenantID)
        {
            string Query = @" SELECT  * FROM tools.Brand WHERE TenantID = @TenantID AND ISNULL(IsDeleted, 0) = 0 ;";
            List<Brand> results = new List<Brand>();
            using (var conn = new SqlConnection(connString))
            {
                conn.Open();
                results = conn.Query<Brand>(Query, new { TenantID = tenantID }, null, true, 100000).ToList();
                conn.Close();
            }
            return results;
        }
    }
}