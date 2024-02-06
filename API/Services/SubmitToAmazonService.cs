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
    public class SubmitToAmazonService
    {
        StringBuilder stbSqlQuery = new StringBuilder();
        string connString = clsConnection.CommonConnString();

        public TenantsHeaderDetail GetHeaderDetailsForAmazon(int tenantID)
        {
            TenantsHeaderDetail header = new TenantsHeaderDetail();
            header = AmazonHelper.GetHeaderDetails(tenantID);
            return header;
        }

        //--------------*Post Method Submit To Amazon Start*-----------------------//
        public string SubmitToAmazon(TenantsHeaderDetail mdlTenantsHeaderDetail)
        {
            string msg = "";
            int tenantID = Convert.ToInt32(mdlTenantsHeaderDetail.tenantID);
            try
            {
                stbSqlQuery.Remove(0, stbSqlQuery.Length);
                TenantsHeaderDetail headerDetails = AmazonHelper.GetHeaderDetails(tenantID);

                int hdnheaderid = 0;
                if (headerDetails != null)
                {
                    hdnheaderid = Convert.ToInt32(headerDetails.headerid);
                    if (!string.IsNullOrWhiteSpace(headerDetails.brandaaiaid))
                    {
                        mdlTenantsHeaderDetail.IsBrandVerifiedtxt = "Yes";
                        bool IsBrandVerified = BrandHelper.IsBrandVerified(headerDetails.brandaaiaid, tenantID);
                        if (IsBrandVerified)
                        {
                            mdlTenantsHeaderDetail.IsBrandVerifiedtxt = "Yes";
                        }
                    }
                    else
                    {
                        mdlTenantsHeaderDetail.IsBrandVerifiedtxt = "No";
                    }
                }
                else
                {
                    hdnheaderid = Convert.ToInt32(mdlTenantsHeaderDetail.headerid);
                }


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
                    Query = @"INSERT INTO [tools].[TenantsHeaderDetail] ([company], [sendername], [senderphone], [transferdate], [brandaaiaid], [documenttitle], [effectivedate], [tenantID], [createddate]) 
                        VALUES
                    (@company,@sendername,@senderphone,@transferdate,@brandaaiaid,@documenttitle,@effectivedate,@TenantID,@createddate)";
                }
                string UpdateBrandinPartQuery = @"UPDATE tools.Parts_" + tenantID + " SET BrandID = '" + mdlTenantsHeaderDetail.brandaaiaid + "' WHERE ISNULL(BrandID,'') = ''";
                List<Brand> BrandList = BrandHelper.GetAllBrands(tenantID);
                string InsertBrandQuery = @"INSERT INTO tools.Brand(TenantID, Company, Phone, BrandCode, BrandName)
            VALUES(" + tenantID + ", '" + mdlTenantsHeaderDetail.company + "', '" + mdlTenantsHeaderDetail.senderphone + "', '" + mdlTenantsHeaderDetail.brandaaiaid + "', '" + mdlTenantsHeaderDetail.company + "')";
                using (var conn = new SqlConnection(connString))
                {
                    conn.Open();
                    conn.Query(UpdateBrandinPartQuery);
                    if (BrandList.Count == 0)
                    {
                        conn.Query(InsertBrandQuery);
                    }
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
                bool CheckUserFitments = AmazonHelper.CheckUserFitmentsTable(tenantID);

                if (!CheckUserFitments)
                {
                    return "You have not added a fitments. So first add fitments then Submit To Amazon.";
                }

                int submitLimit = commonMethods.Submitlimit();

                int remaining_attempt = 0;
                bool IsinLimit = true;
                string limitreachMessage = "";
                DataTable dttodayreq = AmazonHelper.GetTodayReq(tenantID);
                if (dttodayreq != null && dttodayreq.Rows.Count > 0)
                {
                    if (dttodayreq.Rows.Count >= submitLimit)
                    {
                        IsinLimit = false;
                        limitreachMessage = "You have crossed the submission limit for today. You can make request for submission on next day.";
                    }
                    else
                    {
                        IsinLimit = true;
                        remaining_attempt = submitLimit - dttodayreq.Rows.Count;
                        remaining_attempt = remaining_attempt - 1;
                        string Message = "Amazon Submission" + "|" + "We have accepted your request for amazon submission." + "|" + "You have ##count## submissions left for today. Please complete all the add/edit parts and fitment-related work for a day and submit all those changes together.";
                        limitreachMessage = Message;
                        limitreachMessage = limitreachMessage.Replace("##count##", remaining_attempt.ToString());

                    }
                }

                if (IsinLimit == false)
                {
                    return limitreachMessage;
                }

                bool IsPendingFitments = AmazonHelper.IsFitmentsAvailableToSubmit(tenantID, mdlTenantsHeaderDetail.brandaaiaid);
                bool IsRequestPending = AmazonHelper.CheckPendingReq(tenantID, mdlTenantsHeaderDetail.brandaaiaid);

                if (IsPendingFitments == true && IsRequestPending == false)
                {
                    // Add request to Submit to amazon
                    AmazonHelper.SaveUserDownloadedData(tenantID, "AMAZON", mdlTenantsHeaderDetail.brandaaiaid);

                    if (string.IsNullOrWhiteSpace(limitreachMessage))
                    {
                        return "Your fitment data has been submitted to Amazon. Once Amazon received your data, we will send you a notification with the official process report.";
                    }
                    else
                    {
                        return limitreachMessage;
                    }
                }
                else
                {
                    return "You have already submitted your fitment to Amazon";
                }
            }
            catch
            {
                msg = "Something went wrong! Please contact to system admin!";
            }
            return msg;
        }

        //--------------*Post Method Submit To Amazon Verification Start*-----------------------//
        public string submitToAmazonVerification(TenantsHeaderDetail mdlTenantsHeaderDetail)
        {
            string msg = "";
            int tenantID = Convert.ToInt32(mdlTenantsHeaderDetail.tenantID);
            try
            {
                string Res = "";
                StringBuilder stbSqlQuery = new StringBuilder();
                stbSqlQuery.Remove(0, stbSqlQuery.Length);
                TenantsHeaderDetail headerDetails = AmazonHelper.GetHeaderDetails(tenantID);
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
                    Query = @"INSERT INTO [tools].[TenantsHeaderDetail] ([company], [sendername], [senderphone], [transferdate], [brandaaiaid], [documenttitle], [effectivedate], [tenantID], [createddate]) 
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

                bool CheckUserFitments = AmazonHelper.CheckUserFitmentsTable(tenantID);

                bool IsPendingFitments = AmazonHelper.IsFitmentsAvailableToSubmit(tenantID, mdlTenantsHeaderDetail.brandaaiaid);
                bool IsRequestPending = AmazonHelper.CheckPendingReqVerifyAmazon(tenantID, mdlTenantsHeaderDetail.brandaaiaid);
                bool IsBrandExists = AmazonHelper.IsBrandExists(tenantID, mdlTenantsHeaderDetail.brandaaiaid);
                int TotalHours = AmazonHelper.CheckHoursDifference(tenantID, mdlTenantsHeaderDetail.brandaaiaid);
                string BrandVerifyBufferDay = commonMethods.BrandVerificationBufferDays();

                if (TotalHours <= Convert.ToInt32(BrandVerifyBufferDay) && IsBrandExists)
                {
                    Res = "You'll be able to try this process again in ##Hours## hour(s). Remember, brand verification can only be done once within a 24-hour period.";
                    Res = Res.Replace("##Hours##", BrandVerifyBufferDay);
                }
                else if (!CheckUserFitments)
                {
                    Res = "You have not added a fitments. So first add fitments then Submit To Amazon.";
                }
                else if (!IsPendingFitments)
                {
                    Res = "You have submitted all fitments.";
                }
                else if (IsRequestPending)
                {
                    Res = "Your previous request is under process, please wait while we are processing.";
                }
                else
                {
                    AmazonHelper.SaveUserDownloadedDataBrand(tenantID, "AMAZON", mdlTenantsHeaderDetail.brandaaiaid);
                    Res = "Request succefully recived! please wait while we are processing your request.";
                }

                msg = Res;
            }
            catch
            {
                msg = "Something went wrong! Please contact to system admin!";
            }
            return msg;
        }

    }
}
