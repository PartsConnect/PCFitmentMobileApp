using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLSendErrorEmail
    {
        public string Subject { get; set; }
        public string Message { get; set; }
    }
}
