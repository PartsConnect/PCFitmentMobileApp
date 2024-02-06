using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using PartsConnectWebTools.Models.Custom;
using System.Data.SqlClient;
using System.Security.Cryptography.X509Certificates;
using System.Security.Cryptography;
using System.Text;
using System.IO;
using Newtonsoft.Json;
using System.Globalization;
using System.Data;
using TestRestAPI.Models.Utilities;
using PCFitment_API.Models;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using Microsoft.Extensions.Primitives;
using Microsoft.AspNetCore.Http.HttpResults;
using System.Diagnostics.Metrics;
using System.Numerics;
using System.Transactions;
using System.Xml.Linq;
using Dapper;
using System.Drawing;

namespace PartsConnectWebTools.Helpers
{
    public class TenantsSubscriptionHelper
    {
        protected static StringBuilder stbSqlQuery = new StringBuilder();
        protected static string connString = clsConnection.CommonConnString();
        protected static int gblIntcount = 0;

        public TenantsSubscriptionHelper() { }

        public static PaymentDetail GetLastPaymentOfUser(int tenantID)
        {
            PaymentDetail paymentDetailMain = new PaymentDetail();
            TenantsSubscriptionModel tenantsSubscriptionModelMain = new TenantsSubscriptionModel();

            using (SqlConnection connection = new SqlConnection(connString))
            {
                connection.Open();
                stbSqlQuery.Clear();
                stbSqlQuery.Append(@" SELECT TOP 1 SubscriptionCode,FirstName,LastName,Address1,Address2,City,State
                ,Postal,Country, BillingAmount, EndDate FROM tools.FitmentTenantSubscriptions 
                WHERE TenantID = '" + tenantID + "' ORDER BY FitmentTenantSubscriptionsID DESC ");

                using (SqlCommand command = new SqlCommand(stbSqlQuery.ToString(), connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            TenantsSubscriptionModel tenantsSubscriptionModelSub = new TenantsSubscriptionModel()
                            {
                                SubscriptionCode = reader["SubscriptionCode"] is DBNull ? string.Empty : reader["SubscriptionCode"].ToString(),
                                FirstName = reader["FirstName"] is DBNull ? string.Empty : reader["FirstName"].ToString(),
                                LastName = reader["LastName"] is DBNull ? string.Empty : reader["LastName"].ToString(),
                                Address1 = reader["Address1"] is DBNull ? string.Empty : reader["Address1"].ToString(),
                                Address2 = reader["Address2"] is DBNull ? string.Empty : reader["Address2"].ToString(),
                                City = reader["City"] is DBNull ? string.Empty : reader["City"].ToString(),
                                State = reader["State"] is DBNull ? string.Empty : reader["State"].ToString(),
                                Postal = reader["Postal"] is DBNull ? string.Empty : reader["Postal"].ToString(),
                                Country = reader["Country"] is DBNull ? string.Empty : reader["Country"].ToString(),
                                BillingAmount = reader["BillingAmount"] is DBNull ? string.Empty : reader["BillingAmount"].ToString(),
                                EndDate = reader["EndDate"] is DBNull ? string.Empty : reader["EndDate"].ToString()
                            };
                            tenantsSubscriptionModelMain = tenantsSubscriptionModelSub;
                        }
                    }
                }

                if (tenantsSubscriptionModelMain != null)
                {
                    paymentDetailMain = GetPaymentDetails(tenantsSubscriptionModelMain);
                }

                connection.Close();
            }

            return paymentDetailMain;

        }

        public static PaymentDetail GetPaymentDetails(TenantsSubscriptionModel tenant)
        {
            PaymentDetail tenantdata = new PaymentDetail();
            tenantdata.ActivateNow = tenant.ActivateNow;
            tenantdata.SubscriptionCode = tenant.SubscriptionCode;
            tenantdata.FirstName = tenant.FirstName;
            tenantdata.LastName = tenant.LastName;
            tenantdata.Add1 = tenant.Address1;
            tenantdata.Add2 = tenant.Address2;
            tenantdata.City = tenant.City;
            tenantdata.State = tenant.State;
            tenantdata.Country = tenant.Country;
            tenantdata.PostalCode = tenant.Postal;
            tenantdata.Name = tenant.Name;
            tenantdata.Company = tenant.Company;
            tenantdata.Email = tenant.Email;
            tenantdata.Phone = tenant.Phone;
            tenantdata.BillingAmount = tenant.BillingAmount;
            tenantdata.EndDate = tenant.EndDate;
            return tenantdata;
        }

        public static string GetPaymenntList(int tenantID, int size, int Start, bool IsCount)
        {
            //IEnumerable<MDLGetBillingHistory> Payment;
            string Query = @"
                             SELECT * FROM (
                             SELECT FitmentTenantSubscriptionsID, ActivationDate AS ActiveDate,
                                         CASE WHEN ISNULL(BillingAmount,0)=0 THEN 'Trial - Up to 10 SKUs' 
                                         WHEN ISNULL(BillingAmount,0)=10 THEN 'Basic Plan – Up to 100 SKUs' 
                             			WHEN ISNULL(BillingAmount,0)=15 THEN 'Basic Plan – Up to 100 SKUs' 
                                         ELSE 'Tiered Plan – Up to '+CAST(BillingAmount*20 AS VARCHAR)+' SKUs' END AS PlanName,
                                         '$'+CAST(ISNULL(BillingAmount,0)AS VARCHAR(50)) AS 'Amount',
                                         CASE WHEN ISNULL(SubscriptionID,'')!='' THEN 'Stripe' ELSE 'Paypal' END AS PaymentProvider
                                         FROM tools.FitmentTenantSubscriptions 
                                         WHERE TenantID=@TenantID 
                             			UNION
                             SELECT DISTINCT id AS FitmentTenantSubscriptionsID, ActivationDate AS ActiveDate,
                                         'eBay Plan Up to '+CAST(CAST(ISNULL(BillingAmount,0) AS INT) * 50 AS VARCHAR)+' SKUs'   AS PlanName,
                                         '$'+CAST(ISNULL(BillingAmount,0)AS VARCHAR(50)) AS 'Amount',
                                         CASE WHEN ISNULL(SubscriptionID,'')!='' THEN 'Stripe' ELSE 'Paypal' END AS PaymentProvider
                                         FROM tools.eBayTenantSubscriptions 
                                         WHERE TenantID=@TenantID ) AS t ORDER BY FitmentTenantSubscriptionsID DESC ";

            if (!IsCount)
            {
                Query += @" OFFSET ((" + size + ")*((" + Start + ") - 1)) ROWS FETCH NEXT(" + size + ") ROWS ONLY ; ";
            }

            //using (var conn = new SqlConnection(clsConnection.CommonConnString()))
            //{
            //    conn.Open();
            //    Payment = conn.Query<MDLGetBillingHistory>(Query, new { TenantID = tenantID }).ToList();
            //    conn.Close();
            //}
            return Query;
        }

        public static TenantsSubscriptionModel GetUserSubscriptionByID(int FitSubsid, int tenantid)
        {
            //string Query = @" SELECT TenantID, SubscriptionCode, FirstName, LastName, Created, BillingAmount, EndDate, CustomerID, ActivationDate AS ActiveDate, SubscriptionID, StripePlanID, StripeInvoiceId FROM tools.FitmentTenantSubscriptions  WHERE FitmentTenantSubscriptionsID =@FitmentTenantSubscriptionsID AND   TenantID = @TenantID  ";
            string Query = @"SELECT TenantID, SubscriptionCode, FirstName, LastName, Created, BillingAmount, EndDate, CustomerID, ActivationDate AS ActiveDate, SubscriptionID, StripePlanID, StripeInvoiceId 
                FROM tools.FitmentTenantSubscriptions  WHERE FitmentTenantSubscriptionsID =@FitmentTenantSubscriptionsID AND   TenantID = @TenantID
                UNION
                SELECT TenantID, SubscriptionCode, FirstName, LastName, Created, BillingAmount, EndDate, CustomerID, ActivationDate AS ActiveDate, SubscriptionID, StripePlanID, StripeInvoiceId 
                FROM tools.eBayTenantSubscriptions  WHERE ID =@FitmentTenantSubscriptionsID AND   TenantID = @TenantID ";
            TenantsSubscriptionModel userdetails = new TenantsSubscriptionModel();
            using (var conn = new SqlConnection(connString))
            {
                conn.Open();
                userdetails = conn.Query<TenantsSubscriptionModel>(Query, new { FitmentTenantSubscriptionsID = FitSubsid, TenantID = tenantid }).FirstOrDefault();
                conn.Close();
            }
            return userdetails;
        }

        public static TenantSubscriptionUserDetails GetUsereBaySubscriptionDetails(int tenantID)
        {
            string Query = "SELECT TOP(1) * FROM tools.eBayTenantSubscriptions  WHERE TenantID=@TenantID  ORDER BY id DESC";
            TenantSubscriptionUserDetails UserDetails = new TenantSubscriptionUserDetails();
            using (var conn = new SqlConnection(connString))
            {
                conn.Open();
                UserDetails = conn.Query<TenantSubscriptionUserDetails>(Query, new { TenantID = tenantID }).FirstOrDefault();
                conn.Close();
            }
            return UserDetails;
        }

    }
}