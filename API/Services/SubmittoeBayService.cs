using Dapper;
using PartsConnectWebTools.Data;
using PartsConnectWebTools.Helpers;
using PartsConnectWebTools.Models.Custom;
using PCFitment_API.Models;
using System.Data.SqlClient;
using System.Text;
using TestRestAPI.Models.Utilities;

namespace PCFitment_API.Services
{
    public class SubmittoeBayService
    {
        StringBuilder stbSqlQuery = new StringBuilder();
        string connString = clsConnection.CommonConnString();

        public MDLGeteBayDetails GeteBayDetails(int tenantID)
        {
            MDLGeteBayDetails mDLGeteBayDetails = new MDLGeteBayDetails();
            StringBuilder stbSqlQuery = new StringBuilder();
            string ebaylimitreach = "no", RedirectToAction = "EBAYSUBMIT", message = "", EbayloginMsg = "", msg = "No";
            string displaymsg = "", IsAvailableeBayFitment = "no", IsPendingReq = "no", LastSubmitError = "";

            if (commonMethods.IsEbayUser())
            {
                string ActivePlan = TenantsSubscriptionHelper.GetLastPaymentOfUser(tenantID).SubscriptionCode;
                string ExpiryDate = TenantsSubscriptionHelper.GetLastPaymentOfUser(tenantID).EndDate;

                if (commonMethods.IsAdmin(Convert.ToString(tenantID)))
                {
                    ExpiryDate = Convert.ToString(DateTime.Now.AddDays(10));
                    ActivePlan = "UN";
                }

                if (ActivePlan == "UN")
                {
                    if (commonMethods.IsEbayUser())
                    {
                        IEnumerable<PartDisplay> partsSKU;
                        partsSKU = PartsHelper.GetAllSKU(tenantID);
                        mDLGeteBayDetails.SKUlist = partsSKU;
                        string IsInlimt = EBayExportHelper.CheckLimit(tenantID);
                        if (IsInlimt.ToLower() == "no")
                        {
                            ebaylimitreach = "yes";
                            RedirectToAction = "UpgradeView";
                        }
                        message = "";
                        EbayloginMsg = "";
                        commonMethods.getsetEbaytokenforUser(out message, out EbayloginMsg, tenantID);
                        if (message == "Yes")
                        {
                            RedirectToAction = "Exports";
                            msg = message;
                            displaymsg = EbayloginMsg;
                        }

                        if (PartsHelper.GeteBayFitmentcount(tenantID) > 0)
                        {
                            IsAvailableeBayFitment = "yes";
                        }

                        string status = "";
                        status = AmazonHelper.CheckEbayPendingRequest(tenantID);

                        if (status == "EBAY")
                        {
                            IsPendingReq = "yes";
                        }

                        LastSubmitError = AmazonHelper.CheckeBaySubmitError(tenantID);

                        if (LastSubmitError != "")
                        {
                            LastSubmitError = LastSubmitError;
                        }
                    }
                }
            }


            mDLGeteBayDetails.ebaylimitreach = ebaylimitreach;
            mDLGeteBayDetails.RedirectToAction = RedirectToAction;
            mDLGeteBayDetails.IsAvailableeBayFitment = IsAvailableeBayFitment;
            mDLGeteBayDetails.msg = msg;
            mDLGeteBayDetails.displaymsg = displaymsg;
            mDLGeteBayDetails.IsPendingReq = IsPendingReq;
            mDLGeteBayDetails.LastSubmitError = LastSubmitError;

            return mDLGeteBayDetails;
        }

        //--------------*Post Method Submit To eBay Start*-----------------------//
        public string SubmittoeBay(PARSubmittoeBay pARSubmittoeBay)
        {
            string msgCode = "", ReqType = "EBAY";
            int tenantID = Convert.ToInt32(pARSubmittoeBay.tenantID);
            try
            {
                string status = "";
                if ((ReqType.ToUpper() == "EBAY") && (PartsHelper.GeteBayFitmentcount(tenantID) > 0))
                {
                    string IsPending = AmazonHelper.CheckEbayPendingRequest(tenantID);
                    if (IsPending == "EBAY")
                    {
                        status = "No";
                        msgCode = "P";
                    }
                    else
                    {
                        status = AmazonHelper.MakeRequestForEbay(ReqType, tenantID);
                        msgCode = "S";
                    }
                }
                else
                {
                    msgCode = "FC";
                }
               
            }
            catch
            {
                msgCode = "SF";
            }
            return msgCode;
        }

    }
}
