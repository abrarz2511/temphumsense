using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Project3
{
    // Class for handling the reading of candlesticks from a file
    internal class DATACANDLESTICK
    {
        /// <summary>
        /// Reads candlestick data from a file and returns a list of Candlestick objects.
        /// </summary>
        /// <param name="filePath">The path of the file containing the candlestick data.</param>
        /// <returns>A list of Candlestick objects.</returns>
        public List<Candlestick> ReadCandlesticksFromFile(string filePath)
        {
            var candlesticks = new List<Candlestick>(); // List to store the candlestick data

            // Open the file using StreamReader to read its contents
            using (StreamReader sr = new StreamReader(filePath, Encoding.UTF8))
            {
                // Skip the header line of the file
                var header = sr.ReadLine();

                // Read the file line by line until the end of the stream
                while (!sr.EndOfStream)
                {
                    // Read each line, remove any leading/trailing whitespace, and create a new Candlestick object
                    string line = sr.ReadLine();
                    line.Trim(); // Trim any extra whitespace from the line

                    // Create a new Candlestick object from the line and add it to the list
                    candlesticks.Add(new Candlestick(line));
                }
            }

            // Return the list of candlesticks
            return candlesticks;
        }
    }
}
