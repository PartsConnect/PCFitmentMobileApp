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
    public class BatchUploadController : ControllerBase
    {
        private readonly BatchUploadService _batchUploadService;

        public BatchUploadController(BatchUploadService batchUploadService)
        {
            _batchUploadService = batchUploadService;
        }

        [Authorize]
        [HttpGet("GetFitmentsUploadDetails")]
        public IActionResult GetFitmentsUploadDetails([FromQuery] string tenantID)
        {
            MDLGetFitmentsUploadDetails data = null;
            IActionResult response = Unauthorized();
            try
            {
                data = _batchUploadService.GetFitmentsUploadDetails(Convert.ToInt32(tenantID));
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
        [HttpGet("GetFitmentsLastUploadedFiles")]
        public IActionResult GetFitmentsLastUploadedFiles([FromQuery] string tenantID)
        {
            IEnumerable<MDLGetFitmentsLastUploadedFiles> data = null;
            IActionResult response = Unauthorized();
            try
            {
                data = (IEnumerable<MDLGetFitmentsLastUploadedFiles>)_batchUploadService.GetFitmentsLastUploadedFiles(Convert.ToInt32(tenantID));

                if (data.Any())
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.OK, Status = HttpStatusCode.OK.ToString(), Message = Messages.CON_Success, data });
                }
                else
                {
                    response = Ok(new { StatusCode = (int)HttpStatusCode.NoContent, Status = HttpStatusCode.NoContent.ToString(), Message = Messages.CON_No_Files_Found, data });
                }
            }
            catch (Exception ex)
            {
                response = Ok(new { StatusCode = (int)HttpStatusCode.InternalServerError, Status = HttpStatusCode.InternalServerError.ToString(), Message = ex.Message + ", Please contact to system admin", data });
            }

            return response;
        }

        [Authorize]
        [HttpPost("AddFitments")]
        public IActionResult AddFitments(MDLAddFitmentData addFitmentData)
        {
            IActionResult response = Unauthorized();
            string msgCode = "", STMSG = "", MSG = "";
            int STCODE = 0;

            try
            {
                msgCode = _batchUploadService.AddFitments(Convert.ToInt32(addFitmentData.userfilesid),Convert.ToInt32(addFitmentData.tenantID));
                if (!string.IsNullOrEmpty(msgCode) && msgCode == "S")
                {
                    MSG = "Your data has been added to your PCFitment Account.";
                    STCODE = (int)HttpStatusCode.OK;
                    STMSG = Convert.ToString(HttpStatusCode.OK);
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

    }
}
