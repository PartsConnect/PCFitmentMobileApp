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
using PartsConnectWebTools.Data;

namespace PCFitment_API.Controllers.v1
{
    [ApiController]
    [Route("api/v1")]
    public class SubmittoeBayController : ControllerBase
    {
        private readonly SubmittoeBayService _submittoeBayService;
        private readonly GeneralService _generalService;

        public SubmittoeBayController(SubmittoeBayService submittoeBayService, GeneralService generalService)
        {
            _submittoeBayService = submittoeBayService;
            _generalService = generalService;
        }

        [Authorize]
        [HttpGet("GeteBayDetails")]
        public IActionResult GeteBayDetails([FromQuery] string tenantID)
        {
            MDLGeteBayDetails data = null;
            IActionResult response = Unauthorized();
            try
            {
                data = (MDLGeteBayDetails)_submittoeBayService.GeteBayDetails(Convert.ToInt32(tenantID));

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
        [HttpPost("SubmittoeBay")]
        public IActionResult SubmittoeBay(PARSubmittoeBay pARSubmittoeBay)
        {
            IActionResult response = Unauthorized();
            string msgCode = "", STMSG = "", MSG = "";
            int STCODE = 0;
            try
            {
                msgCode = _submittoeBayService.SubmittoeBay(pARSubmittoeBay);

                if (!string.IsNullOrEmpty(msgCode) && msgCode == "S")
                {
                    MSG = "Process Success!";
                    STCODE = (int)HttpStatusCode.OK;
                    STMSG = Convert.ToString(HttpStatusCode.OK);
                }
                else if (!string.IsNullOrEmpty(msgCode) && msgCode == "P")
                {
                    MSG = "Request Pending!, Please Check it into Web!";
                    STCODE = (int)HttpStatusCode.OK;
                    STMSG = Convert.ToString(HttpStatusCode.OK);
                }
                else if (!string.IsNullOrEmpty(msgCode) && msgCode == "FC")
                {
                    MSG = "Fitment Count is not enough, Please Check it into Web!";
                    STCODE = (int)HttpStatusCode.OK;
                    STMSG = Convert.ToString(HttpStatusCode.OK);
                }
                else if (!string.IsNullOrEmpty(msgCode) && msgCode == "SF")
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

    }
}
