using Microsoft.AspNetCore.Mvc;
using PCFitment_API.Services;
using PCFitment_API.Models;
using System.Net;
using TestRestAPI.Models.Utilities;
using Microsoft.AspNetCore.Authorization;

namespace PCFitment_API.Controllers.v1
{
    [ApiController]
    [Route("api/v1")]
    public class InheritedPartsController : ControllerBase
    {
        private readonly InheritedPartsService _inheritedPartsService;

        public InheritedPartsController(InheritedPartsService inheritedPartsService)
        {
            _inheritedPartsService = inheritedPartsService;
        }

        [Authorize]
        [HttpGet("GetInheritedPartDetails")]
        public IActionResult GetInheritedPartDetails([FromQuery] string partID = "0", string TenantID = "0")
        {
            MDLInheritedParts data = null;
            IActionResult response = Unauthorized();


            Int64 ReceivedPartID = Convert.ToInt64(partID);
            Int64 ReceivedTenantID = Convert.ToInt64(TenantID);

            try
            {
                data = (MDLInheritedParts)_inheritedPartsService.GetInheritedPartDetails(ReceivedPartID, ReceivedTenantID);

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
        [HttpPost("AddInheritedPart")]
        public IActionResult AddInheritedPart(MDLInheritedParts mDLInherited)
        {
            IActionResult response = Unauthorized();
            string Response = "";
            string[] ArrResponse = new string[2];
            string MSG = "", MSGCode = "", STMSG = "";
            int STCODE = 0;
            try
            {
                Response = _inheritedPartsService.AddInheritedPart(mDLInherited);

                if (!string.IsNullOrEmpty(Response))
                {
                    ArrResponse = Response.Split('|');
                    MSGCode = ArrResponse[0];
                    MSG = ArrResponse[1];

                    if (MSGCode.ToLower() == "s")
                    {
                        STCODE = (int)HttpStatusCode.OK;
                        STMSG = Convert.ToString(HttpStatusCode.OK);
                    }

                    if (MSGCode.ToLower() == "f")
                    {
                        STCODE = (int)HttpStatusCode.NoContent;
                        STMSG = Convert.ToString(HttpStatusCode.NoContent);
                    }
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
        [HttpGet("GetInheritedPartList")]
        public IActionResult GetInheritedPartList([FromQuery] string partID = "0", string TenantID = "0")
        {
            IEnumerable<MDLInheritedParts> data = null;
            IActionResult response = Unauthorized();

            Int64 ReceivedPartID = Convert.ToInt64(partID);
            Int64 ReceivedTenantID = Convert.ToInt64(TenantID);

            try
            {
                data = (IEnumerable<MDLInheritedParts>)_inheritedPartsService.GetInheritedPartList(ReceivedPartID, ReceivedTenantID);

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

    }
}
