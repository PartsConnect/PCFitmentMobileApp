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
    public class AutosyncController : ControllerBase
    {
        private readonly AutosyncService _autosyncService;

        public AutosyncController(AutosyncService autosyncService)
        {
            _autosyncService = autosyncService;
        }

        [Authorize]
        [HttpGet("GetAutosync")]
        public IActionResult GetAutosync([FromQuery] string tenantID)
        {
            IEnumerable<MDLAutosync> data = null;
            IActionResult response = Unauthorized();
            try
            {
                data = (IEnumerable<MDLAutosync>)_autosyncService.GetAutosyncValue(Convert.ToInt32(tenantID));

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
        [HttpPost("SubmitAutosync")]
        public IActionResult SubmitAutosync(MDLAutosync mDLAutosync)
        {
            IActionResult response = Unauthorized();
            string msg = "";
            try
            {
                msg = _autosyncService.SubmitAutosync(mDLAutosync);

                response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = msg });
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin" });
            }

            return response;
        }

    }
}
