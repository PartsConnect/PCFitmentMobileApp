using Microsoft.AspNetCore.Mvc;
using PCFitment_API.Services;
using PCFitment_API.Models;
using System.Net;
using TestRestAPI.Models.Utilities;
using Microsoft.AspNetCore.Authorization;
using PCFitment_API.IService;
using System.Security.Cryptography;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory.Database;
using System.Linq;
using System.Security.Claims;

namespace PCFitment_API.Controllers.v1
{
    [ApiController]
    [Route("api/v1")]
    public class LanguageDetailsController : ControllerBase
    {
        private readonly LanguageDetailsService _mylanguageDetailsService;

        public LanguageDetailsController(LanguageDetailsService mylanguageDetailsService)
        {
            _mylanguageDetailsService = mylanguageDetailsService;
        }

        [AllowAnonymous]
        [HttpGet("GetLanguages")]
        public IActionResult GetLanguages()
        {
            IEnumerable<MDLGetLanguages> data = null;
            IActionResult response = Unauthorized();
            try
            {
                data = (IEnumerable<MDLGetLanguages>)_mylanguageDetailsService.GetLanguages();

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

        [AllowAnonymous]
        [HttpGet("GetLanguageWiseLabels")]
        public IActionResult GetLanguageWiseLabels([FromQuery] string LanguageCode, string DeviceID)
        {
            MDLGetLangAndTermcndAndPrivacyplc data = new MDLGetLangAndTermcndAndPrivacyplc();
            string LCLLanguageCode = LanguageCode;
            string LCLDeviceID = DeviceID;

            if(string.IsNullOrEmpty(LanguageCode))
            {
                LCLLanguageCode = "";
            }
            if (string.IsNullOrEmpty(DeviceID))
            {
                LCLDeviceID = "0";
            }

            IActionResult response = Unauthorized();
            try
            {
                data = (MDLGetLangAndTermcndAndPrivacyplc)_mylanguageDetailsService.GetLangAndTermcndAndPrivacyplc(LCLLanguageCode, LCLDeviceID);

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

    }
}
