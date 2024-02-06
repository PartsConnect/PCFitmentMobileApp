using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace PCFitment_API.Models
{

    public class MDLGetFitmentsSummary
    {
        public string TotalParts { get; set; }
        public string TotalFitments { get; set; }
        public string TotalPartType { get; set; }
        public string TotalCollection { get; set; }
        public string TotalCollectionWithoutParts { get; set; }
        public string TotalUniParts { get; set; }
        public string NewParts { get; set; }
        public string NewFitments { get; set; }
        public string NewPartType { get; set; }
        public string IsBypassfitmentlimit { get; set; }
        public string isUniversalCollectionAcess { get; set; }
        public string IsCollectionAccess { get; set; }

    }
}
