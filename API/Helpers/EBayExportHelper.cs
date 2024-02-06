using Dapper;
using PartsConnectWebTools.Models.Custom;
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
    public class EBayExportHelper
    {

        static string myConnectionString = clsConnection.CommonConnString();

        public static string CheckLimit(int tenantID)
        {
            string isInLimit = "yes";
            int TotalSKUs = PartsHelper.GetTotalSKUs(tenantID);
            TenantSubscriptionUserDetails userDetails = TenantsSubscriptionHelper.GetUsereBaySubscriptionDetails(tenantID);
            int allowed_sku = 0;
            // Without Check with config
            if (userDetails != null && userDetails.BillingAmount > 0)
            {
                allowed_sku = userDetails.BillingAmount * 50;
                if (TotalSKUs >= allowed_sku)
                {
                    isInLimit = "no";
                }
            }
            else
            {
                isInLimit = "no";
            }
            return isInLimit;
        }
    }
}