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

namespace PCFitment_API.Controllers.v1
{
    [ApiController]
    [Route("api/v1")]
    public class GeneralController : ControllerBase
    {
        private readonly GeneralService _generalService;

        public GeneralController(GeneralService generalService)
        {
            _generalService = generalService;
        }

        [Authorize]
        [HttpGet("GetHelpVideosDetails")]
        public IActionResult GetHelpVideosDetails()
        {
            IEnumerable<MDLGetHelpVideosDetails> data = null;
            IActionResult response = Unauthorized();
            try
            {
                data = (IEnumerable<MDLGetHelpVideosDetails>)_generalService.GetHelpVideosDetails();
                if (data != null)
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Help_Videos, data });
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

        [HttpPost("SendNotification")]
        public IActionResult SendNotification(MDLSendNotification sendNotification)
        {
            IActionResult response = Unauthorized();

            try
            {
                _generalService.SendNotification(sendNotification);

                response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Notification });
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin" });
            }

            return response;
        }

    }
}
