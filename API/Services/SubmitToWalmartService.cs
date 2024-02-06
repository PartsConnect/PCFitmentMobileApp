using Dapper;
using Microsoft.EntityFrameworkCore.Metadata.Internal;
using PartsConnectWebTools.Data;
using PartsConnectWebTools.Helpers;
using PartsConnectWebTools.Models.Custom;
using PCFitment_API.Models;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using TestRestAPI.Models.Utilities;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace PCFitment_API.Services
{
    public class SubmitToWalmartService
    {
        StringBuilder stbSqlQuery = new StringBuilder();
        string connString = clsConnection.CommonConnString();

        public TenantsHeaderDetail GetHeaderDetailsForWalmart(int tenantID)
        {
            TenantsHeaderDetail header = new TenantsHeaderDetail();
            header = WalmartHelper.GetHeaderDetails(tenantID);
            return header;
        }

        //--------------*Post Method Submit To Walmart Start*-----------------------//
        public string SubmitToWalmart(TenantsHeaderDetail mdlTenantsHeaderDetail)
        {
            string msg = "";
            int tenantID = Convert.ToInt32(mdlTenantsHeaderDetail.tenantID);
            try
            {
                stbSqlQuery.Remove(0, stbSqlQuery.Length);
                TenantsHeaderDetail headerDetails = WalmartHelper.GetHeaderDetails(tenantID);
                int hdnheaderid = 0;
                if (headerDetails != null)
                {
                    hdnheaderid = Convert.ToInt32(headerDetails.headerid);
                }
                else
                {
                    hdnheaderid = Convert.ToInt32(mdlTenantsHeaderDetail.headerid);
                }

                // Add or update entry in tools.TenantsHeaderDetail in partsconnect database
                string Query = @"";
                if (hdnheaderid > 0)
                {
                    Query = @" UPDATE tools.TenantsHeaderDetail SET company = @company ,sendername = @sendername ,
                    senderphone = @senderphone ,transferdate = @transferdate ,documenttitle = @documenttitle ,
                    effectivedate = @effectivedate 
                    WHERE tenantID = @TenantID";
                }
                else
                {
                    Query = @"INSERT INTO [tools].[TenantsHeaderDetail] ([company], [sendername], [senderphone], [transferdate], [brandaaiaid], [documenttitle], [effectivedate],[tenantID], [createddate]) 
                        VALUES
                    (@company,@sendername,@senderphone,@transferdate,@brandaaiaid,@documenttitle,@effectivedate,@TenantID,@createddate)";
                }

                using (var conn = new SqlConnection(connString))
                {
                    conn.Open();
                    conn.Query(Query, new
                    {
                        TenantID = tenantID,
                        company = mdlTenantsHeaderDetail.company,
                        sendername = mdlTenantsHeaderDetail.sendername,
                        senderphone = mdlTenantsHeaderDetail.senderphone,
                        transferdate = mdlTenantsHeaderDetail.transferdate,
                        brandaaiaid = mdlTenantsHeaderDetail.brandaaiaid,
                        documenttitle = mdlTenantsHeaderDetail.documenttitle,
                        effectivedate = mdlTenantsHeaderDetail.effectivedate,
                        createddate = DateTime.Now.ToString("yyyy-MM-dd")
                    });
                    conn.Close();
                }
                bool CheckUserFitments = WalmartHelper.CheckUserFitmentsTable(tenantID);

                if (!CheckUserFitments)
                {
                    msg = "You have not added a fitments. So first add fitments then Submit To Walmart.";
                }
                bool IsPendingFitments = WalmartHelper.IsFitmentsAvailableToSubmit(tenantID);

                if (IsPendingFitments == true)
                {
                    WalmartHelper.SaveUserDownloadedData(tenantID, "WALMART", mdlTenantsHeaderDetail.brandaaiaid);
                    msg = "Your fitment data has been submitted to Walmart. Once Walmart received your data, we will send you a notification with the official process report.";

                }
                else
                {
                    msg = "You have already submitted your fitment to Walmart.";
                }

                int TotalFitments = WalmartHelper.GetTotalFitments(tenantID);
                bool XML = WalmartHelper.ValidateButton(tenantID, "XML");
                bool Excel = WalmartHelper.ValidateButton(tenantID, "EXCEL");
                string EstimatedTime = WalmartHelper.GetValidationTime(tenantID);
                AmazonData UserSubmitToWalmartInfo = WalmartHelper.GetUserSubmissionInfo(tenantID, "WALMART");
                if (UserSubmitToWalmartInfo != null)
                {
                    bool SubmitToWalmart = UserSubmitToWalmartInfo.IsInProcess;
                    string SubmitDate = UserSubmitToWalmartInfo.SubmissionDate.ToString("MM/dd/yyyy");
                    string SubmissiDate = UserSubmitToWalmartInfo.SubmissionDate.ToString("MM/dd/yyyy");
                    string RequestType = "Walmart";
                }
            }
            catch
            {
                msg = "Something went wrong! Please contact to system admin!";
            }
            return msg;
        }

    }
}
