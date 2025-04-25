using System;
using System.Collections.Generic;

namespace Project3
{
    // Represents a smart candlestick with peak, valley, and margin information
    public class Smartcandlestick
    {
        public bool peak { get; set; } // Indicates if this candlestick is a peak
        public bool valley { get; set; } // Indicates if this candlestick is a valley
        public int index { get; set; } // The index of the candlestick in the list
        public int lMargin { get; set; } // Left margin for peak/valley detection
        public int rMargin { get; set; } // Right margin for peak/valley detection
        public DateTime date { get; set; } // The date of the candlestick

        // Default constructor initializes a Smartcandlestick object with default values
        public Smartcandlestick()
        {
            peak = false; // Default peak is false
            valley = false; // Default valley is false
            index = -1; // Default index is -1 indicating an uninitialized state
            lMargin = -1; // Default left margin is -1 (uninitialized)
            rMargin = -1; // Default right margin is -1 (uninitialized)
        }

        // Constructor that allows initializing the Smartcandlestick with specific values
        public Smartcandlestick(bool Peak, bool Valley, int Index, int LMargin, int RMargin)
        {
            peak = Peak; // Set peak to the given value
            valley = Valley; // Set valley to the given value
            index = Index; // Set index to the given value
            lMargin = LMargin; // Set left margin to the given value
            rMargin = RMargin; // Set right margin to the given value
        }
    }

    // Represents a wave that starts at a peak and ends at a valley (or vice versa)
    public class Wave
    {
        public decimal startPrice { get; set; } // The starting price of the wave
        public decimal endPrice { get; set; } // The ending price of the wave
        public int startIndex { get; set; } // The index of the starting point of the wave
        public int endIndex { get; set; } // The index of the ending point of the wave
        public bool up { get; set; } // Indicates if the wave is moving upwards
        public bool down { get; set; } // Indicates if the wave is moving downwards
        public DateTime startDate { get; set; } // The start date of the wave
        public DateTime endDate { get; set; } // The end date of the wave
        public string displayDate { get; set; } // The formatted date range for display

        // Default constructor initializes the Wave object with default values
        public Wave()
        {
            startDate = DateTime.MinValue; // Default start date to a minimal date
            endDate = DateTime.MinValue; // Default end date to a minimal date
            startIndex = 0; // Default start index to 0
            endIndex = 0; // Default end index to 0
            up = false; // Default wave direction is not upwards
            down = false; // Default wave direction is not downwards
            displayDate = string.Empty; // Default display date is an empty string
        }
    }
}
