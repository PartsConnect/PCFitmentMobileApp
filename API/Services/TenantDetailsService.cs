using Dapper;
using PartsConnectWebTools.Helpers;
using PartsConnectWebTools.Models.Custom;
using PCFitment_API.Models;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using TestRestAPI.Models.Utilities;

namespace PCFitment_API.Services
{
    public class TenantDetailsService
    {
        StringBuilder stbSqlQuery = new StringBuilder();
        string connString = clsConnection.CommonConnString();
        int gblIntcount = 0;

        //--------------* Get Tenant Details Start *-----------------------//

        public MDLGetTenantDetails GetTenantDetails(int tenantID)
        {
            MDLGetTenantDetails getTenantDetailsMain = new MDLGetTenantDetails();

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT * FROM [tools].[Tenants] WHERE ID = '" + tenantID + "';");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            MDLGetTenantDetails getTenantDetailsSub = new MDLGetTenantDetails()
                            {
                                ID = reader["ID"] is DBNull ? string.Empty : reader["ID"].ToString(),
                                Name = reader["Name"] is DBNull ? string.Empty : reader["Name"].ToString(),
                                Address1 = reader["Address1"] is DBNull ? string.Empty : reader["Address1"].ToString(),
                                Address2 = reader["Address2"] is DBNull ? string.Empty : reader["Address2"].ToString(),
                                City = reader["City"] is DBNull ? string.Empty : reader["City"].ToString(),
                                State = reader["State"] is DBNull ? string.Empty : reader["State"].ToString(),
                                Province = reader["Province"] is DBNull ? string.Empty : reader["Province"].ToString(),
                                Zipcode = reader["Zipcode"] is DBNull ? string.Empty : reader["Zipcode"].ToString(),
                                CreateDate = reader["CreateDate"] is DBNull ? string.Empty : reader["CreateDate"].ToString(),
                                CreateBy = reader["CreateBy"] is DBNull ? string.Empty : reader["CreateBy"].ToString(),
                                Email = reader["Email"] is DBNull ? string.Empty : reader["Email"].ToString(),
                                FirstName = reader["FirstName"] is DBNull ? string.Empty : reader["FirstName"].ToString(),
                                LastName = reader["LastName"] is DBNull ? string.Empty : reader["LastName"].ToString(),
                                Phone = reader["Phone"] is DBNull ? string.Empty : reader["Phone"].ToString(),
                                Company = reader["Company"] is DBNull ? string.Empty : reader["Company"].ToString(),
                                Country = reader["Country"] is DBNull ? string.Empty : reader["Country"].ToString(),
                                DataProviderName = reader["DataProviderName"] is DBNull ? string.Empty : reader["DataProviderName"].ToString(),
                                CustomerID = reader["CustomerID"] is DBNull ? string.Empty : reader["CustomerID"].ToString(),
                                InActive = reader["InActive"] is DBNull ? string.Empty : reader["InActive"].ToString(),
                                apiusername = reader["apiusername"] is DBNull ? string.Empty : reader["apiusername"].ToString(),
                                apipassword = reader["apipassword"] is DBNull ? string.Empty : reader["apipassword"].ToString(),
                                IseBayAccess = reader["IseBayAccess"] is DBNull ? string.Empty : reader["IseBayAccess"].ToString(),
                                IsUniversalPartAccess = reader["IsUniversalPartAccess"] is DBNull ? string.Empty : reader["IsUniversalPartAccess"].ToString(),
                                IsCustomFitmentsAccess = reader["IsCustomFitmentsAccess"] is DBNull ? string.Empty : reader["IsCustomFitmentsAccess"].ToString(),
                                IsMultiBrandAccess = reader["IsMultiBrandAccess"] is DBNull ? string.Empty : reader["IsMultiBrandAccess"].ToString(),
                                IsMailNotification = reader["IsMailNotification"] is DBNull ? string.Empty : reader["IsMailNotification"].ToString(),
                                BrandLimit = reader["BrandLimit"] is DBNull ? string.Empty : reader["BrandLimit"].ToString(),
                                IsBigCommerceAccess = reader["IsBigCommerceAccess"] is DBNull ? string.Empty : reader["IsBigCommerceAccess"].ToString(),
                                IsWalmartAccess = reader["IsWalmartAccess"] is DBNull ? string.Empty : reader["IsWalmartAccess"].ToString(),
                                IsWalmartSetupDone = reader["IsWalmartSetupDone"] is DBNull ? string.Empty : reader["IsWalmartSetupDone"].ToString(),
                                WeChatID = reader["WeChatID"] is DBNull ? string.Empty : reader["WeChatID"].ToString()
                            };
                            getTenantDetailsMain = getTenantDetailsSub;
                        }
                    }
                }
                connection.Close();
            }
            return getTenantDetailsMain;
        }

        //--------------*Edit Tenant Details Start*-----------------------//

        public string QREditTenantDetails(MDLEDITTenantDetails mEDITTenantDetails)
        {
            string msg = "";
            try
            {
                using (SqlConnection connection = new SqlConnection(connString))
                {
                    connection.Open();
                    stbSqlQuery.Clear();
                    stbSqlQuery.Append(@"UPDATE [tools].[Tenants] SET
                                    [FirstName] = '" + mEDITTenantDetails.FirstName + @"'
                                    ,[LastName]= '" + mEDITTenantDetails.LastName + @"'
                                    ,[Phone]= '" + mEDITTenantDetails.Phone + @"'
                                    ,[WeChatID]= '" + mEDITTenantDetails.WeChatID + @"'
                               WHERE ID = " + mEDITTenantDetails.tenantID + "");

                    SqlCommand cmd = new SqlCommand(stbSqlQuery.ToString(), connection);
                    cmd.ExecuteNonQuery();
                    connection.Close();
                }

                msg = "Successfully updated!";
            }
            catch
            {
                msg = "Something went wrong! Please contact to system admin!";
            }
            return msg;
        }

        public string QRResetPassword(MDLResetPassword mResetPassword)
        {
            string msg = "";
            try
            {
                if (IsOldPasswordMatch(mResetPassword))
                {
                    if (mResetPassword.NewPassword == mResetPassword.ConfirmPassword)
                    {
                        using (SqlConnection connection = new SqlConnection(connString))
                        {
                            connection.Open();
                            stbSqlQuery.Clear();
                            stbSqlQuery.Append(@"UPDATE [tools].[Tenants] SET
                                    [password]= '" + commonMethods.DecryptPassword(mResetPassword.NewPassword) + @"'
                               WHERE ID = " + mResetPassword.tenantID + "");

                            SqlCommand cmd = new SqlCommand(stbSqlQuery.ToString(), connection);
                            cmd.ExecuteNonQuery();
                            connection.Close();
                        }
                        msg = "S";
                    }
                    else
                    {
                        msg = "CNM";
                    }
                }
                else
                {
                    msg = "ONM";
                }
            }
            catch
            {
                msg = "OTH";
            }
            return msg;
        }

        //----------------*Tenant Plan Details*---------------------//
        public MDLGetTenantPlanDetails GetTenantPlanDetails(int tenantID)
        {
            MDLGetTenantPlanDetails getTenantPlanDetailsMain = new MDLGetTenantPlanDetails();
            bool IsAdmin = commonMethods.IsAdmin(Convert.ToString(tenantID));
            string lclRunningPlan = "", lcleBayPlan = "";

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT TOP(1) *,
                                       CASE
                                         WHEN SubscriptionCode = 'Trial' AND '" + IsAdmin.ToString().ToLower() + @"' = 'false' AND
                                           ISNULL(BillingAmount, '0') = 0 THEN 'Trial'
                                         WHEN SubscriptionCode = 'STD' AND '" + IsAdmin.ToString().ToLower() + @"' = 'false' AND
                                           ISNULL(BillingAmount, '0') <= 15 THEN 'Basic Plan'
                                         ELSE ('Tiered Plan ($' + CAST(ISNULL(BillingAmount,'0') AS VARCHAR) + '/Month)')
                                       END AS RunningPlan
                                     FROM tools.FitmentTenantSubscriptions
                                     WHERE TenantID = " + tenantID + @"
                                     ORDER BY FitmentTenantSubscriptionsID DESC ");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            lclRunningPlan = reader["RunningPlan"] is DBNull ? string.Empty : reader["RunningPlan"].ToString();
                        }
                    }
                    if (!string.IsNullOrEmpty(lclRunningPlan))
                    {
                        getTenantPlanDetailsMain.RunningPlan = "Base Subscription - " + lclRunningPlan;
                    }
                    else
                    {
                        getTenantPlanDetailsMain.RunningPlan = "No Base plan subscribed!";
                    }
                }
                connection.Close();
            }

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT TOP(1) *, ('$' + CAST(BillingAmount AS VARCHAR) + ' for ' + CAST((CAST(BillingAmount AS BIGINT)*50) AS VARCHAR) + ' SKUs') AS eBayPlan
                                        FROM tools.eBayTenantSubscriptions 
                                        WHERE TenantID = " + tenantID + "; ");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            lcleBayPlan = reader["eBayPlan"] is DBNull ? string.Empty : reader["eBayPlan"].ToString();
                        }
                    }
                    if (!string.IsNullOrEmpty(lcleBayPlan))
                    {
                        getTenantPlanDetailsMain.eBayPlan = "eBay Subscription - " + lcleBayPlan;
                    }
                    else
                    {
                        getTenantPlanDetailsMain.eBayPlan = "No eBay plan subscribed";
                    }
                }
                connection.Close();
            }

            return getTenantPlanDetailsMain;
        }

        //----------------*Fitment Information & Updated Info Since Last Data Submission *---------------------//
        public MDLGetFitmentsSummary GetFitmentsSummary(int tenantID)
        {
            MDLGetFitmentsSummary getFitmentsSummaryMain = new MDLGetFitmentsSummary();
            bool IsBypassfitmentlimit = false, IsCollectionAccess = false;

            //Get Total # of Parts
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetPartsQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.TotalParts = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            // Get Total # of Fitments
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetFitmentsSavedCountQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.TotalFitments = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            // Get Total # of PartType
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetTotalPartQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.TotalPartType = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            //Get Total Number of  New Part and PartType
            //Get Total # of New PartType
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetNewPartTypeQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.NewPartType = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            // Get Total # of New Part
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetNewPartsQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.NewParts = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            // Get Total # of New Fitments
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetNewFitmentsQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.NewFitments = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            // Get Tenant Account Info
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append("SELECT * FROM tools.Tenants WHERE ID = " + tenantID + "");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            IsBypassfitmentlimit = (reader["IsBypassfitmentlimit"] is DBNull) || string.IsNullOrEmpty(reader["IsBypassfitmentlimit"].ToString()) ? Convert.ToBoolean("true") : Convert.ToBoolean(reader["IsBypassfitmentlimit"]);
                            IsCollectionAccess = (reader["IsCollectionAccess"] is DBNull) || string.IsNullOrEmpty(reader["IsCollectionAccess"].ToString()) ? Convert.ToBoolean("true") : Convert.ToBoolean(reader["IsCollectionAccess"]);
                        }
                    }
                }
                connection.Close();
            }

            getFitmentsSummaryMain.IsBypassfitmentlimit = Convert.ToString(IsBypassfitmentlimit);
            getFitmentsSummaryMain.IsCollectionAccess = Convert.ToString(IsCollectionAccess);

            if (IsBypassfitmentlimit == true && IsCollectionAccess == true)
            {
                //Get Total # of UnitParts
                using (SqlConnection connection = new SqlConnection(connString))
                {
                    connection.Open();
                    stbSqlQuery.Clear();
                    stbSqlQuery.Append(CustomQueryBuillder.GetTotalUniversalPartsQuery(tenantID));

                    using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                    {
                        object value = command.ExecuteScalar();
                        if (value != null)
                        {
                            gblIntcount = Convert.ToInt32(value);
                        }
                        getFitmentsSummaryMain.TotalUniParts = Convert.ToString(gblIntcount);
                        gblIntcount = 0;
                    }
                    connection.Close();
                }

                //Get Total # of Collection
                using (SqlConnection connection = new SqlConnection(connString))
                {
                    connection.Open();
                    stbSqlQuery.Clear();
                    stbSqlQuery.Append(CustomQueryBuillder.GetTotalCollectionQuery(tenantID));

                    using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                    {
                        object value = command.ExecuteScalar();
                        if (value != null)
                        {
                            gblIntcount = Convert.ToInt32(value);
                        }
                        getFitmentsSummaryMain.TotalCollection = Convert.ToString(gblIntcount);
                        gblIntcount = 0;
                    }
                    connection.Close();
                }

                //Get Total # of Collection Without Parts
                using (SqlConnection connection = new SqlConnection(connString))
                {
                    connection.Open();
                    stbSqlQuery.Clear();
                    stbSqlQuery.Append(CustomQueryBuillder.GetTotalCollectionWithoutPartsQuery(tenantID));

                    using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                    {
                        object value = command.ExecuteScalar();
                        if (value != null)
                        {
                            gblIntcount = Convert.ToInt32(value);
                        }
                        getFitmentsSummaryMain.TotalCollectionWithoutParts = Convert.ToString(gblIntcount);
                        gblIntcount = 0;
                    }
                    connection.Close();
                }

                getFitmentsSummaryMain.isUniversalCollectionAcess = "yes";
            }
            else
            {
                getFitmentsSummaryMain.TotalUniParts = "0";
                getFitmentsSummaryMain.TotalCollection = "0";
                getFitmentsSummaryMain.TotalCollectionWithoutParts = "0";
                getFitmentsSummaryMain.isUniversalCollectionAcess = "no";
            }

            return getFitmentsSummaryMain;
        }

        //----------------* Most Recent Export *---------------------//
        public MDLGetMostRecentExportInfo GetMostRecentExport(int tenantID)
        {
            MDLGetMostRecentExportInfo getMostRecentExportMain = new MDLGetMostRecentExportInfo();

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT TOP 5 *  
                            FROM tools.ExportRequest 
                            WHERE ISNULL(status,'p') = 'c'  
                            AND TenantID = " + tenantID + @"
                            AND CAST(CreatedDate AS DATE) > ( CAST(GETDATE() - 30 AS DATE)) 
                            AND (ISNULL(RequestCode,'') ='XML' OR ISNULL(RequestCode,'') ='EXCEL')
                            AND ISNULL(FileLocation,'') <> ''
                            ORDER BY ID DESC ");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            MDLGetMostRecentExport getMostRecentExportSUB = new MDLGetMostRecentExport()
                            {
                                strFilePath = commonMethods.RecentExportedFileDownload() + "?FileName=" + Path.GetFileName(reader["FileLocation"] is DBNull ? string.Empty : reader["FileLocation"].ToString()),
                                ExportDate = reader["CreatedDate"] is DBNull ? string.Empty : reader["CreatedDate"].ToString(),
                                ExportType = reader["RequestCode"] is DBNull ? string.Empty : reader["RequestCode"].ToString()
                            };
                            getMostRecentExportMain.MostRecentExportsList.Add(getMostRecentExportSUB);
                        }
                    }
                }
                connection.Close();
            }

            return getMostRecentExportMain;
        }

        public MDLGetDashboardRequiredData GetDashboardRequiredData(int tenantID)
        {
            MDLGetDashboardRequiredData mDLGetDashboardRequiredData = new MDLGetDashboardRequiredData();

            //** Tenant Plan Details Start **//
            MDLGetTenantPlanDetails getTenantPlanDetailsMain = new MDLGetTenantPlanDetails();
            bool IsAdmin = commonMethods.IsAdmin(Convert.ToString(tenantID));
            string lclRunningPlan = "", lcleBayPlan = "";

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT TOP(1) *,
                                       CASE
                                         WHEN SubscriptionCode = 'Trial' AND '" + IsAdmin.ToString().ToLower() + @"' = 'false' AND
                                           ISNULL(BillingAmount, '0') = 0 THEN 'Trial'
                                         WHEN SubscriptionCode = 'STD' AND '" + IsAdmin.ToString().ToLower() + @"' = 'false' AND
                                           ISNULL(BillingAmount, '0') <= 15 THEN 'Basic Plan'
                                         ELSE ('Tiered Plan ($' + CAST(ISNULL(BillingAmount,'0') AS VARCHAR) + '/Month)')
                                       END AS RunningPlan
                                     FROM tools.FitmentTenantSubscriptions
                                     WHERE TenantID = " + tenantID + @"
                                     ORDER BY FitmentTenantSubscriptionsID DESC ");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            lclRunningPlan = reader["RunningPlan"] is DBNull ? string.Empty : reader["RunningPlan"].ToString();
                        }
                    }
                    if (!string.IsNullOrEmpty(lclRunningPlan))
                    {
                        getTenantPlanDetailsMain.RunningPlan = "Base Subscription - " + lclRunningPlan;
                    }
                    else
                    {
                        getTenantPlanDetailsMain.RunningPlan = "No Base plan subscribed!";
                    }
                }
                connection.Close();
            }

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT TOP(1) *, ('$' + CAST(BillingAmount AS VARCHAR) + ' for ' + CAST((CAST(BillingAmount AS BIGINT)*50) AS VARCHAR) + ' SKUs') AS eBayPlan
                                        FROM tools.eBayTenantSubscriptions 
                                        WHERE TenantID = " + tenantID + "; ");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            lcleBayPlan = reader["eBayPlan"] is DBNull ? string.Empty : reader["eBayPlan"].ToString();
                        }
                    }
                    if (!string.IsNullOrEmpty(lcleBayPlan))
                    {
                        getTenantPlanDetailsMain.eBayPlan = "eBay Subscription - " + lcleBayPlan;
                    }
                    else
                    {
                        getTenantPlanDetailsMain.eBayPlan = "No eBay plan subscribed";
                    }
                }
                connection.Close();
            }

            mDLGetDashboardRequiredData.TenantPlanDetails.Add(getTenantPlanDetailsMain);

            //** Fitment Information & Updated Info Since Last Data Submission Start **//
            MDLGetFitmentsSummary getFitmentsSummaryMain = new MDLGetFitmentsSummary();
            bool IsBypassfitmentlimit = false, IsCollectionAccess = false;

            //Get Total # of Parts
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetPartsQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.TotalParts = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            // Get Total # of Fitments
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetFitmentsSavedCountQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.TotalFitments = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            // Get Total # of PartType
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetTotalPartQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.TotalPartType = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            //Get Total Number of  New Part and PartType
            //Get Total # of New PartType
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetNewPartTypeQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.NewPartType = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            // Get Total # of New Part
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetNewPartsQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.NewParts = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            // Get Total # of New Fitments
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(CustomQueryBuillder.GetNewFitmentsQuery(tenantID));

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    object value = command.ExecuteScalar();
                    if (value != null)
                    {
                        gblIntcount = Convert.ToInt32(value);
                    }
                    getFitmentsSummaryMain.NewFitments = Convert.ToString(gblIntcount);
                    gblIntcount = 0;
                }
                connection.Close();
            }

            // Get Tenant Account Info
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append("SELECT * FROM tools.Tenants WHERE ID = " + tenantID + "");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            IsBypassfitmentlimit = (reader["IsBypassfitmentlimit"] is DBNull) || string.IsNullOrEmpty(reader["IsBypassfitmentlimit"].ToString()) ? Convert.ToBoolean("true") : Convert.ToBoolean(reader["IsBypassfitmentlimit"]);
                            IsCollectionAccess = (reader["IsCollectionAccess"] is DBNull) || string.IsNullOrEmpty(reader["IsCollectionAccess"].ToString()) ? Convert.ToBoolean("true") : Convert.ToBoolean(reader["IsCollectionAccess"]);
                        }
                    }
                }
                connection.Close();
            }

            getFitmentsSummaryMain.IsBypassfitmentlimit = Convert.ToString(IsBypassfitmentlimit);
            getFitmentsSummaryMain.IsCollectionAccess = Convert.ToString(IsCollectionAccess);

            if (IsBypassfitmentlimit == true && IsCollectionAccess == true)
            {
                //Get Total # of UnitParts
                using (SqlConnection connection = new SqlConnection(connString))
                {
                    connection.Open();
                    stbSqlQuery.Clear();
                    stbSqlQuery.Append(CustomQueryBuillder.GetTotalUniversalPartsQuery(tenantID));

                    using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                    {
                        object value = command.ExecuteScalar();
                        if (value != null)
                        {
                            gblIntcount = Convert.ToInt32(value);
                        }
                        getFitmentsSummaryMain.TotalUniParts = Convert.ToString(gblIntcount);
                        gblIntcount = 0;
                    }
                    connection.Close();
                }

                //Get Total # of Collection
                using (SqlConnection connection = new SqlConnection(connString))
                {
                    connection.Open();
                    stbSqlQuery.Clear();
                    stbSqlQuery.Append(CustomQueryBuillder.GetTotalCollectionQuery(tenantID));

                    using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                    {
                        object value = command.ExecuteScalar();
                        if (value != null)
                        {
                            gblIntcount = Convert.ToInt32(value);
                        }
                        getFitmentsSummaryMain.TotalCollection = Convert.ToString(gblIntcount);
                        gblIntcount = 0;
                    }
                    connection.Close();
                }

                //Get Total # of Collection Without Parts
                using (SqlConnection connection = new SqlConnection(connString))
                {
                    connection.Open();
                    stbSqlQuery.Clear();
                    stbSqlQuery.Append(CustomQueryBuillder.GetTotalCollectionWithoutPartsQuery(tenantID));

                    using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                    {
                        object value = command.ExecuteScalar();
                        if (value != null)
                        {
                            gblIntcount = Convert.ToInt32(value);
                        }
                        getFitmentsSummaryMain.TotalCollectionWithoutParts = Convert.ToString(gblIntcount);
                        gblIntcount = 0;
                    }
                    connection.Close();
                }

                getFitmentsSummaryMain.isUniversalCollectionAcess = "yes";
            }
            else
            {
                getFitmentsSummaryMain.TotalUniParts = "0";
                getFitmentsSummaryMain.TotalCollection = "0";
                getFitmentsSummaryMain.TotalCollectionWithoutParts = "0";
                getFitmentsSummaryMain.isUniversalCollectionAcess = "no";
            }

            mDLGetDashboardRequiredData.FitmentsSummary.Add(getFitmentsSummaryMain);

            //----------------* Most Recent Export Start *---------------------//

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT TOP 5 *  
                            FROM tools.ExportRequest 
                            WHERE ISNULL(status,'p') = 'c'  
                            AND TenantID = " + tenantID + @"
                            AND CAST(CreatedDate AS DATE) > ( CAST(GETDATE() - 30 AS DATE)) 
                            AND (ISNULL(RequestCode,'') ='XML' OR ISNULL(RequestCode,'') ='EXCEL')
                            AND ISNULL(FileLocation,'') <> ''
                            ORDER BY ID DESC ");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            MDLGetMostRecentExport getMostRecentExportSUB = new MDLGetMostRecentExport()
                            {
                                strFilePath = commonMethods.RecentExportedFileDownload() + "?FileName=" + Path.GetFileName(reader["FileLocation"] is DBNull ? string.Empty : reader["FileLocation"].ToString()),
                                ExportDate = reader["CreatedDate"] is DBNull ? string.Empty : reader["CreatedDate"].ToString(),
                                ExportType = reader["RequestCode"] is DBNull ? string.Empty : reader["RequestCode"].ToString()
                            };
                            mDLGetDashboardRequiredData.MostRecentExport.Add(getMostRecentExportSUB);
                        }
                    }
                }
                connection.Close();
            }

            string ExpiryDate = TenantsSubscriptionHelper.GetLastPaymentOfUser(tenantID).EndDate;

            if (Convert.ToDateTime(ExpiryDate).Date < DateTime.Now.Date && !commonMethods.IsAdmin(Convert.ToString(tenantID)))
            {
                mDLGetDashboardRequiredData.IsUserExpired = "Yes";
            }

            return mDLGetDashboardRequiredData;
        }

        //----------------* My Parts & Fitment *---------------------//
        public object GetMyPartsAndFitmentList(int tenantID, int item, string searchValue, int IMPageSize, int IMpageNumber, bool IsCount = false)
        {
            MDLGetMyPartsAndFitmentInfo getMyPartsAndFitmentInfoMain = new MDLGetMyPartsAndFitmentInfo();
            int totalRecordCount = 0;

            string tablename = "tools.Parts_" + tenantID;
            string fitmentTable = "tools.FitmentsSaved_" + tenantID;
            string Query = "";

            CustomQueryBuillder.AddUniversalCollectionColumns(tenantID);
            Query = CustomQueryBuillder.BuildQueryForParts(item, tenantID, tablename, fitmentTable, IMpageNumber, IMPageSize, searchValue, IsCount);
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(Query);

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (!IsCount)
                        {
                            while (reader.Read())
                            {
                                MDLGetMyPartsAndFitment getMyPartsAndFitmentSub = new MDLGetMyPartsAndFitment
                                {
                                    ID = reader["ID"] is DBNull ? string.Empty : reader["ID"].ToString(),
                                    TenantID = reader["TenantID"] is DBNull ? string.Empty : reader["TenantID"].ToString(),
                                    PartTypeName = reader["PartTypeName"] is DBNull ? string.Empty : reader["PartTypeName"].ToString(),
                                    PartNumber = reader["PartNumber"] is DBNull ? string.Empty : reader["PartNumber"].ToString(),
                                    ASIN = reader["ASIN"] is DBNull ? string.Empty : reader["ASIN"].ToString(),
                                    BrandID = reader["BrandID"] is DBNull ? string.Empty : reader["BrandID"].ToString(),
                                    ManufactureLabel = reader["ManufactureLabel"] is DBNull ? string.Empty : reader["ManufactureLabel"].ToString(),
                                    PartDescription = reader["PartDescription"] is DBNull ? string.Empty : reader["PartDescription"].ToString(),
                                    PartTerminologyID = reader["PartTerminologyID"] is DBNull ? string.Empty : reader["PartTerminologyID"].ToString(),
                                    CollectionID = reader["collectionId"] is DBNull ? string.Empty : reader["collectionId"].ToString()
                                };
                                getMyPartsAndFitmentInfoMain.MyPartsAndFitmentList.Add(getMyPartsAndFitmentSub);
                            }
                        }
                        else
                        {
                            DataTable dt = new DataTable();
                            dt.Load(reader);
                            totalRecordCount = dt.Rows.Count;
                        }
                    }
                }
                connection.Close();
            }
            if (!IsCount)
            {
                return getMyPartsAndFitmentInfoMain;
            }
            else
            {
                return totalRecordCount;
            }
        }

        //----------------* Billing History *---------------------//
        public object GetBillingHistory(int tenantID, int IMPageSize, int IMpageNumber, bool IsCount = false)
        {
            var mDLGetBillingsMain = new List<MDLGetBillingHistory>();
            int totalRecordCount = 0;
            string Query = "";

            Query = TenantsSubscriptionHelper.GetPaymenntList(tenantID, IMPageSize, IMpageNumber, IsCount);
            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(Query);

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    command.Parameters.Add("@TenantID", SqlDbType.Int).Value = tenantID;

                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        if (!IsCount)
                        {
                            while (reader.Read())
                            {
                                MDLGetBillingHistory getBillingsSub = new MDLGetBillingHistory
                                {
                                    ActiveDate = reader["ActiveDate"] is DBNull ? string.Empty : reader["ActiveDate"].ToString(),
                                    PlanName = reader["PlanName"] is DBNull ? string.Empty : reader["PlanName"].ToString(),
                                    FitmentTenantSubscriptionsID = reader["FitmentTenantSubscriptionsID"] is DBNull ? string.Empty : reader["FitmentTenantSubscriptionsID"].ToString(),
                                    PaymentProvider = reader["PaymentProvider"] is DBNull ? string.Empty : reader["PaymentProvider"].ToString(),
                                    Amount = reader["Amount"] is DBNull ? string.Empty : reader["Amount"].ToString(),
                                    InvoiceUrl = DownloadInvoice(reader.GetInt64(reader.GetOrdinal("FitmentTenantSubscriptionsID")), tenantID)
                                };
                                mDLGetBillingsMain.Add(getBillingsSub);
                            }
                        }
                        else
                        {
                            DataTable dt = new DataTable();
                            dt.Load(reader);
                            totalRecordCount = dt.Rows.Count;
                        }
                    }
                }
                connection.Close();
            }
            if (!IsCount)
            {
                return mDLGetBillingsMain;
            }
            else
            {
                return totalRecordCount;
            }
        }

        //----------------* Get Notification History *---------------------//
        public object GetNotificationHistory(int tenantID)
        {
            IEnumerable<MDLGetNotificationHistory> mDLGetNotifications;
            StringBuilder stbSqlQuery = new StringBuilder();

            using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            {
                conn.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT * FROM [dbo].[App_Notification_History] WHERE TenantID = @TenantID AND Flagdeleted = 0 AND IsNotificationSent = 1 ORDER BY App_NotificationHistoryID DESC ");
                mDLGetNotifications = conn.Query<MDLGetNotificationHistory>(stbSqlQuery.ToString(), new { TenantID = tenantID }).ToList();
                conn.Close();
            }

            return mDLGetNotifications;
        }

        public string DeleteNotificationHistory(int tenantId, int App_NotificationHistoryID)
        {
            string msg = "";
            try
            {
                string Query = "UPDATE [dbo].[App_Notification_History] SET Flagdeleted = 1,DeletedDate = GETDATE() WHERE App_NotificationHistoryID = " + App_NotificationHistoryID + " AND TenantID = " + tenantId + "";
                using (var conn = new SqlConnection(connString))
                {
                    conn.Open();
                    conn.Query(Query);
                    conn.Close();
                }

                msg = "Successfully updated!";
            }
            catch
            {
                msg = "Something went wrong! Please contact to system admin!";
            }
            return msg;
        }

        public string DeActivateDeviceId(string DeviceID)
        {
            string msg = "";
            try
            {
                string Query = "UPDATE [dbo].[App_Settings] SET ISActive = 0 WHERE DeviceID = '" + DeviceID + "'";
                using (var conn = new SqlConnection(connString))
                {
                    conn.Open();
                    conn.Query(Query);
                    conn.Close();
                }

                msg = "Successfully updated!";
            }
            catch
            {
                msg = "Something went wrong! Please contact to system admin!";
            }
            return msg;
        }

        //----------------*SUB Used Methods*---------------------//

        public bool IsOldPasswordMatch(MDLResetPassword sDLResetPassword)
        {
            bool IsMatched = false;
            DataTable dt = new DataTable();

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@"SELECT * FROM [tools].[Tenants]
                                           WHERE [password] = '" + commonMethods.DecryptPassword(sDLResetPassword.OldPassword) + "' COLLATE Latin1_General_CS_AS AND ID = " + sDLResetPassword.tenantID + " ");
                SqlCommand cmd = new SqlCommand(stbSqlQuery.ToString(), connection);
                cmd.ExecuteNonQuery();
                dt.Load(cmd.ExecuteReader());
                connection.Close();
            }

            if (dt.Rows.Count > 0)
            {
                IsMatched = true;
            }

            return IsMatched;
        }
        public string DownloadInvoice(long subsid, int tenantID)
        {
            //TenantsSubscriptionModel subs_details = TenantsSubscriptionHelper.GetUserSubscriptionByID(Convert.ToInt32(subsid), tenantID);
            string InvoiceUrl = "";
            //string secret = commonMethods.GetStripeSecretKey();

            //var api = new StripeWrapper.StripeWrapper(secret);
            //InvoiceUrl = api.GetInvoicePDFURL(subs_details.CustomerID, subs_details.SubscriptionID, subs_details.StripeInvoiceId, subs_details.ActiveDate, subs_details.BillingAmount, subs_details.StripePlanID);

            string StaticInvoiceUrl =  commonMethods.GetInvoiceStaticFile();
            InvoiceUrl = StaticInvoiceUrl;

            return InvoiceUrl;
        }

    }
}
