using Microsoft.AspNetCore.Mvc;
using PCFitment_API.Services;
using PCFitment_API.Models;
using System.Net;
using TestRestAPI.Models.Utilities;
using Microsoft.AspNetCore.Authorization;
using PCFitment_API.IService;
using System.Security.Cryptography;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using System;
using System.Collections.Generic;

namespace PCFitment_API.Controllers.v1
{
    [ApiController]
    [Route("api/v1")]
    public class TenantDetailsController : ControllerBase
    {
        private readonly TenantDetailsService _tenantDetailsService;

        public TenantDetailsController(TenantDetailsService tenantDetailsService)
        {
            _tenantDetailsService = tenantDetailsService;
        }

        [Authorize]
        [HttpGet("GetTenantDetails")]
        public IActionResult GetTenantDetails([FromQuery] string tenantID)
        {
            MDLGetTenantDetails data = null;
            IActionResult response = Unauthorized();
            string ReceivedtenantID = string.IsNullOrEmpty(tenantID) ? "0" : tenantID;
            try
            {
                data = _tenantDetailsService.GetTenantDetails(Convert.ToInt32(ReceivedtenantID));
                if (data != null)
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Success, data });
                }
                else
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = Messages.CON_No_Data_Found, data });
                }
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin", data });
            }

            return response;
        }

        [Authorize]
        [HttpPost("EditTenantDetails")]
        public IActionResult EditTenantDetails(MDLEDITTenantDetails tenantDetails)
        {
            IActionResult response = Unauthorized();

            try
            {
                _tenantDetailsService.QREditTenantDetails(tenantDetails);

                response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Edit_Data });
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin" });
            }

            return response;
        }

        [Authorize]
        [HttpPost("ResetPassword")]
        public IActionResult ResetPasswod(MDLResetPassword resetPassword)
        {
            IActionResult response = Unauthorized();
            string msgType = "", MSG = "", STMSG = "";
            int STCODE = 0;
            try
            {
                msgType = _tenantDetailsService.QRResetPassword(resetPassword);

                if (msgType.ToUpper() == "S")
                {
                    MSG = "Password changed successfully!";
                    STCODE = (int)HttpStatusCode.OK;
                    STMSG = Convert.ToString(HttpStatusCode.OK);
                }
                else if (msgType.ToUpper() == "CNM")
                {
                    MSG = "Password and confirm password does not match!";
                    STCODE = (int)HttpStatusCode.NoContent;
                    STMSG = Convert.ToString(HttpStatusCode.NoContent);
                }
                else if (msgType.ToUpper() == "ONM")
                {
                    MSG = "Old password do not match, please retype!";
                    STCODE = (int)HttpStatusCode.NoContent;
                    STMSG = Convert.ToString(HttpStatusCode.NoContent);
                }
                else
                {
                    MSG = "Something went wrong! Please contact to system admin!";
                    STCODE = (int)HttpStatusCode.NoContent;
                    STMSG = Convert.ToString(HttpStatusCode.NoContent);
                }
                response = Ok(new { StatusCode = STCODE, Status = STMSG, Message = MSG });

            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin" });
            }

            return response;
        }

        [Authorize]
        [HttpGet("GetTenantPlanDetails")]
        public IActionResult GetTenantPlanDetails([FromQuery] string tenantID)
        {
            MDLGetTenantPlanDetails data = null;
            IActionResult response = Unauthorized();
            string ReceivedtenantID = string.IsNullOrEmpty(tenantID) ? "0" : tenantID;
            try
            {
                data = _tenantDetailsService.GetTenantPlanDetails(Convert.ToInt32(ReceivedtenantID));
                if (data != null)
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Success, data });
                }
                else
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = Messages.CON_No_Data_Found, data });
                }
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin", data });
            }

            return response;
        }

        [Authorize]
        [HttpGet("GetFitmentsSummary")]
        public IActionResult GetFitmentsSummary([FromQuery] string tenantID)
        {
            MDLGetFitmentsSummary data = null;
            IActionResult response = Unauthorized();
            string ReceivedtenantID = string.IsNullOrEmpty(tenantID) ? "0" : tenantID;

            try
            {
                data = _tenantDetailsService.GetFitmentsSummary(Convert.ToInt32(ReceivedtenantID));
                if (data != null)
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Success, data });
                }
                else
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = Messages.CON_No_Data_Found, data });
                }
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin", data });
            }

            return response;
        }

        [Authorize]
        [HttpGet("GetMostRecentExport")]
        public IActionResult GetMostRecentExport([FromQuery] string tenantID)
        {
            MDLGetMostRecentExportInfo data = null;
            IActionResult response = Unauthorized();
            string ReceivedtenantID = string.IsNullOrEmpty(tenantID) ? "0" : tenantID;

            try
            {
                data = _tenantDetailsService.GetMostRecentExport(Convert.ToInt32(ReceivedtenantID));
                if (data != null && data.MostRecentExportsList.Any())
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Success, data });
                }
                else
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = Messages.CON_No_Data_Found, data });
                }
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin", data });
            }

            return response;
        }

        [Authorize]
        [HttpGet("GetDashboardRequiredData")]
        public IActionResult GetDashboardRequiredData([FromQuery] string tenantID)
        {
            MDLGetDashboardRequiredData data = null;
            IActionResult response = Unauthorized();
            string ReceivedtenantID = string.IsNullOrEmpty(tenantID) ? "0" : tenantID;

            try
            {
                data = _tenantDetailsService.GetDashboardRequiredData(Convert.ToInt32(ReceivedtenantID));
                if (data != null)
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Success, data });
                }
                else
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = Messages.CON_No_Data_Found, data });
                }
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin", data });
            }

            return response;
        }

        [Authorize]
        [HttpGet("GetBillingHistory")]
        public IActionResult GetBillingHistory([FromQuery] string tenantID, string pageNumber)
        {
            IEnumerable <MDLGetBillingHistory> data = null;
            string ReceivedtenantID = string.IsNullOrEmpty(tenantID) ? "0" : tenantID;
            int IMPageSize = commonMethods.PageSize();
            int IMpageNumber = string.IsNullOrEmpty(pageNumber) ? 1 : int.Parse(pageNumber);
            int totalRecords = 0, totalPages = 0;

            IActionResult response = Unauthorized();
            try
            {
                data = (IEnumerable<MDLGetBillingHistory>)_tenantDetailsService.GetBillingHistory(Convert.ToInt32(ReceivedtenantID), IMPageSize, IMpageNumber, false);
                totalRecords = (int)_tenantDetailsService.GetBillingHistory(Convert.ToInt32(ReceivedtenantID), IMPageSize, IMpageNumber, true);
                totalPages = (int)Math.Ceiling(totalRecords / (decimal)IMPageSize);

                if (data != null)
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Pagesize = IMPageSize, CurrentPage = IMpageNumber, totalRecords = totalRecords, totalPages = totalPages, Message = Messages.CON_Success, data });
                }
                else
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = Messages.CON_No_Data_Found, data });
                }
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin", data });
            }

            return response;
        }

        [Authorize]
        [HttpGet("GetNotificationHistory")]
        public IActionResult GetNotificationHistory([FromQuery] string tenantID)
        {
            IEnumerable<MDLGetNotificationHistory> data = null;
            IActionResult response = Unauthorized();
            try
            {
                data = (IEnumerable<MDLGetNotificationHistory>)_tenantDetailsService.GetNotificationHistory(Convert.ToInt32(tenantID));

                if (data.Any())
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Success, data });
                }
                else
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = Messages.CON_No_Data_Found, data });
                }
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin", data });
            }

            return response;
        }

        [Authorize]
        [HttpPost("DeleteNotificationHistory")]
        public IActionResult DeleteNotificationHistory(MDLDeleteNotificationHistory notificationHistory)
        {
            IActionResult response = Unauthorized();

            try
            {
                _tenantDetailsService.DeleteNotificationHistory(Convert.ToInt32(notificationHistory.tenantID),Convert.ToInt32(notificationHistory.NotificationHistoryID));

                response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Edit_Data });
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin" });
            }

            return response;
        }

        [Authorize]
        [HttpPost("DeActivateDeviceId")]
        public IActionResult DeActivateDeviceId(MDLDeActivateDeviceId deActivateDeviceId)
        {
            IActionResult response = Unauthorized();

            try
            {
                _tenantDetailsService.DeActivateDeviceId(deActivateDeviceId.DeviceId);

                response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Logout_Success });
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin" });
            }

            return response;
        }


    }
}
