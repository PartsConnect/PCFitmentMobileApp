using Dapper;
using PCFitment_API.Models;
using System.Data.SqlClient;
using System.Text;
using PCFitment_API.Models;
using TestRestAPI.Models.Utilities;


namespace PCFitment_API.Services
{
    public class AutosyncService
    {
        public IEnumerable<MDLAutosync> GetAutosyncValue(int tenantID)
        {
            IEnumerable<MDLAutosync> mdlAutosync;
            StringBuilder stbSqlQuery = new StringBuilder();

            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@"SELECT 'true' as IsAmazonAccess, t.IsAmazonAutoSync, t.IseBayAutoSync, t.IsWalmartAutoSync, t.IsWalmartSetupDone AS IsWalmartAccess, 
                                      CASE 
                                          WHEN (SELECT COUNT(*) 
                                                FROM tools.eBayTenantSubscriptions 
                                                WHERE TenantID = @TenantID 
                                                AND CAST(EndDate AS DATE) >= CAST(GETDATE() AS DATE)) > 0 
                                          THEN 'true' 
                                          ELSE 'false' 
                                      END AS IseBayAccess, 
                                      @TenantID AS TenantID 
                                      FROM tools.Tenants t 
                                      WHERE t.Id = @TenantID");
                mdlAutosync = conn.Query<MDLAutosync>(stbSqlQuery.ToString(), new { TenantID = tenantID }).ToList();
                conn.Close();
            }

            return mdlAutosync;
        }

        public string SubmitAutosync(MDLAutosync mDLAutosync)
        {
            string msg;
            int tenantID = Convert.ToInt32(mDLAutosync.TenantID);

            try
            {
                using (var conn = new SqlConnection(clsConnection.CommonConnString()))
                {
                    conn.Open();
                    string query = @"UPDATE tools.Tenants
                                       SET IsAmazonAutoSync = @IsAmazonAutoSync,
                                           IseBayAutoSync = @IseBayAutoSync,
                                           IsWalmartAutoSync = @IsWalmartAutoSync
                                       WHERE Id = @TenantID";

                    conn.Execute(query, new
                    {
                        TenantID = tenantID,
                        IsAmazonAutoSync = mDLAutosync.IsAmazonAutoSync,
                        IseBayAutoSync = mDLAutosync.IseBayAutoSync,
                        IsWalmartAutoSync = mDLAutosync.IsWalmartAutoSync
                    });

                    conn.Close();
                }

                msg = "Success: Autosync data submitted.";
            }
            catch
            {
                msg = "Something went wrong! Please contact to system admin!";
            }
            return msg;
        }
    }
}
