// Basic system types and functionalities
using System;

// Non-generic collections
using System.Collections;

// Generic collections
using System.Collections.Generic;

// Component model and data binding
using System.ComponentModel;

// Data handling
using System.Data;

// Drawing and graphics
using System.Drawing;

// File input/output operations
using System.IO;

// LINQ query operations
using System.Linq;

// Text manipulation
using System.Text;

// Asynchronous programming
using System.Threading.Tasks;

// Windows Forms
using System.Windows.Forms;

// Charting controls for Windows Forms
using System.Windows.Forms.DataVisualization.Charting;

//using namespace for the project 3
namespace Project3
{

    //// Partial class declaration for the main form, inheriting from Form
    public partial class Form_ChartDisplay : Form
    {

        public int count = 0; // Variable for tracking candlestick count
        List<Wave> waves; // List to store up waves
        List<Wave> upwaves; // List to store up waves
        List<Wave> downwaves; // List to store down waves
        public String Path; // Path of the loaded file
        public List<Candlestick> candlesticks; // List of candlesticks filtered by date
        public List<Candlestick> currentFilter; // List of filtered candlesticks based on date range
        DATACANDLESTICK reader; // Instance of stock reader class for file reading
        public List<Smartcandlestick> peakValleyList; // List of peaks and valleys



        public Form_ChartDisplay()
        {
            InitializeComponent(); // Initialize the form

            // Set default date ranges for the date pickers
            dateTimePicker_StartDate.Value = new DateTime(2024, 2, 1);
            dateTimePicker_EndDate.Value = new DateTime(2024, 2, 29);
        }



        // Load the ticker file upon button click
        private void button_LoadTicker_Click(object sender, EventArgs e)
        {
            openFileDialog_LoadTicker.ShowDialog();
        }







        // Handle the event when the file is selected
        private void openFileDialog_LoadTicker_FileOk(object sender, CancelEventArgs e)
        {
            var fileNames = new List<string>(openFileDialog_LoadTicker.FileNames);
            if (fileNames.Count > 0)
            {
                Path = fileNames[0];
                LoadAndProcessFile();
            }
        }


        // Load and process the file
        private void LoadAndProcessFile()
        {
            reader = new DATACANDLESTICK(); // Create stock reader instance for file reading

            loadAndDisplay(); // Load and display the chart

            peakValleyList = findPeakValley(currentFilter, 1); // Find the peaks and valleys
            Show();
            showAnnotations(); // Show annotations on the chart
            updateWaves(); // Update the waves
        }

        public Form_ChartDisplay(DateTime startDate, DateTime endDate, string fileName)
        {

            reader = new DATACANDLESTICK(); // Create stock reader instance for file reading
            InitializeComponent();
            dateTimePicker_StartDate.Value = startDate; // Initialize start date
            dateTimePicker_EndDate.Value = endDate; // Initialize end date
            Path = fileName; // Assign file path

            loadAndDisplay(); // Load and display the chart
            peakValleyList = findPeakValley(currentFilter, 1); // Find the peaks and valleys

            Show();
            showAnnotations(); // Show annotations
            updateWaves(); // Update the waves
        }







        /// <summary>
        /// Loads candlesticks from the specified file and returns them as a list.
        /// </summary>
        /// <param name="fileName">The name of the file to load.</param>
        /// <returns>List of Candlesticks loaded from the file.</returns>
        private List<Candlestick> LoadTicker(string fileName)
        {
            List<Candlestick> listofCandlesticks = reader.ReadCandlesticksFromFile(fileName); // Read candlesticks from file
            // Get the first and second candlestick dates to check if list needs to be reversed
            var first = listofCandlesticks[0].Date;
            var second = listofCandlesticks[1].Date;
            // If the first date is later than the second, reverse the list
            if (first > second)
            {
                listofCandlesticks.Reverse(); // Reverse the list to maintain chronological order
            }
            return listofCandlesticks;

        }





        // Load and display the candlesticks on the chart
        public void loadAndDisplay()
        {
            // Call LoadTicker to load the candlesticks from the file
            candlesticks = LoadTicker(Path);
            // Filter candlesticks based on the date range
            displayStock();
        }







        /// <summary>
        /// Filters candlesticks by the current date range and binds them to the chart.
        /// </summary>
        public void displayStock()
        {
            // Filter candlesticks based on date range
            var filteredCandlesticks = FilterCandlesticksByDate(candlesticks, dateTimePicker_StartDate.Value, dateTimePicker_EndDate.Value);
            currentFilter = filteredCandlesticks; // Assign filtered candlesticks
            NormalizeChart(filteredCandlesticks); // Normalize the chart based on the candlesticks
            chart1.DataSource = filteredCandlesticks; // Bind the filtered candlesticks to the chart
            chart1.DataBind(); // Refresh the chart
        }

        ///filters the candlesticks by the start date and end date
        public List<Candlestick> FilterCandlesticksByDate(List<Candlestick> candlestickList, DateTime startDate, DateTime endDate)
        {
            int innerCount = 0;
            List<Candlestick> updatedList = new List<Candlestick>();
            foreach (Candlestick candlestick in candlestickList)//loop to iterate through candle stick
            {
                count++;
                //if candlestick is within range, add it to the filtered list
                if (candlestick.Date >= startDate && candlestick.Date <= endDate)
                {
                    innerCount++;
                    updatedList.Add(candlestick);
                }
            }//returning the updated list
            count = count - innerCount;
            return updatedList;
        }

        /// <summary>
        /// finds the min and max value of the chart to be able to normalize chart
        /// </summary>
        /// <param name="candlestickList"></param>
        public void NormalizeChart(List<Candlestick> candlestickList)
        {
            //finding max high, min lowd
            decimal minValue = candlestickList.Min(c => c.Low);
            decimal maxValue = candlestickList.Max(c => c.High);

            //finding the padding and subtract from min, and add to max.
            decimal padding = (maxValue - minValue) * 0.05m;
            decimal minY = minValue - padding;
            decimal maxY = maxValue + padding;

            //seting the minY and maxY of the chart area
            chart1.ChartAreas["ChartArea_Candlestick"].AxisY.Minimum = (double)minY;
            chart1.ChartAreas["ChartArea_Candlestick"].AxisY.Maximum = (double)maxY;


        }

        /// <summary>
        /// refresh the candlesticks, peaks, valleys and waves once the refresh button has been clicked.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void button_Refresh_Click(object sender, EventArgs e)
        {
            if (candlesticks == null || candlesticks.Count == 0 || currentFilter == null || currentFilter.Count == 0)
            {
               
                return;
            }

            //update chart
            displayStock();

            //update peaks and valleys
            currentFilter = FilterCandlesticksByDate(candlesticks, dateTimePicker_StartDate.Value, dateTimePicker_EndDate.Value);
            peakValleyList = findPeakValley(currentFilter, hScrollBar_Margin.Value);

            //clear and update annotations
            chart1.Annotations.Clear();
            showAnnotations();
            isInit1 = true;
            isInit2 = true;
            //update waves
            updateWaves();

        }

        /// <summary>
        /// Function that updates the waves list and updates the list boxes showing the waves
        /// </summary>
        public void updateWaves()
        {//clear the chart annotations and strip lines
            chart1.ChartAreas[0].AxisY.StripLines.Clear();
            waves = FindValidWaves(peakValleyList);
            upwaves = getUpWaves(waves);
            downwaves = getDownWaves(waves);
            listBox_UpWaves.DataSource = upwaves;
            listBox_DownWaves.DataSource = downwaves;
        }


        /// <summary>
        /// Updates the peakvalley list when the margin has been changed, also updates the waves.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void hScrollBar1_Scroll(object sender, ScrollEventArgs e)
        {
            if (candlesticks == null || candlesticks.Count == 0 || currentFilter == null || currentFilter.Count == 0)
            {
                
                return;
            }

            label_Margin.Text = hScrollBar_Margin.Value.ToString(); // Update the margin label
            peakValleyList = findPeakValley(currentFilter, hScrollBar_Margin.Value); // Update peakvalley list
            chart1.Annotations.Clear(); // Clear the chart annotations
            showAnnotations(); // Show annotations
            updateWaves(); // Update waves
            isInit1 = true;
            isInit2 = true;
        }








        ///Find all peaks and valleys using the given margin
        public List<Smartcandlestick> findPeakValley(List<Candlestick> candlesticks, int margin)
        {

            // Initialize a list to store peaks and valleys
            var peakList = new List<Smartcandlestick>();

            // Initialize the first peak for the first candlestick
            var firstPeak = new Smartcandlestick();
            firstPeak.index = 0;
            firstPeak.peak = true; // Assume it's a peak initially
            firstPeak.valley = true; // Assume it's a valley initially

            // Initialize the last peak for the last candlestick
            var lastPeak = new Smartcandlestick();
            lastPeak.index = candlesticks.Count - 1;
            lastPeak.peak = true; // Assume it's a peak initially
            lastPeak.valley = true; // Assume it's a valley initially

            // Get the count of candlesticks for later use
            int count = candlesticks.Count - 1;

            // Check the first candlestick to see if it's a peak or valley
            for (int i = 1; i <= margin; i++)
            {
                if (candlesticks[0].High < candlesticks[i].High)
                {
                    firstPeak.peak = false; // Not a peak if any candlestick in the margin is higher
                }
                if (candlesticks[0].Low > candlesticks[i].Low)
                {
                    firstPeak.valley = false; // Not a valley if any candlestick in the margin is lower
                }
            }

            // If the first candlestick is a peak or valley, add it to the peakList
            if (firstPeak.peak || firstPeak.valley)
            {
                firstPeak.date = candlesticks[0].Date; // Set the date for the first peak
                peakList.Add(firstPeak); // Add the first peak to the list
            }

            // Check for peaks and valleys for candlesticks in the middle
            for (int i = margin; i < candlesticks.Count - margin; i++)
            {
                var newPeak = new Smartcandlestick(); // Initialize a new peak

                decimal high = candlesticks[i].High; // Get the high value of the current candlestick
                decimal low = candlesticks[i].Low; // Get the low value of the current candlestick

                newPeak.valley = true; // Assume it's a valley initially
                newPeak.peak = true; // Assume it's a peak initially

                // Check the surrounding candlesticks within the margin to determine if it's a peak or valley
                for (int j = i - margin; j <= i + margin; j++)
                {
                    if (j == i) { continue; } // Skip the current candlestick itself

                    // If any candlestick in the margin is higher than the current one, it can't be a peak
                    if (candlesticks[j].High >= high) { newPeak.peak = false; }

                    // If any candlestick in the margin is lower than the current one, it can't be a valley
                    if (candlesticks[j].Low <= low) { newPeak.valley = false; }
                }

                // If the candlestick is a peak or valley, add it to the peakList
                if (newPeak.peak || newPeak.valley)
                {
                    newPeak.index = i; // Set the index for the new peak
                    newPeak.date = candlesticks[i].Date; // Set the date for the new peak
                    peakList.Add(newPeak); // Add the new peak to the list
                }
            }

            // Check the last candlestick to see if it's a peak or valley
            for (int i = 1; i <= margin; i++)
            {
                if (candlesticks[count].High < candlesticks[count - i].High)
                {
                    lastPeak.peak = false; // Not a peak if any candlestick in the margin is higher
                }
                if (candlesticks[count].Low > candlesticks[count - i].Low)
                {
                    lastPeak.valley = false; // Not a valley if any candlestick in the margin is lower
                }
            }

            // If the last candlestick is a peak or valley, add it to the peakList
            if (lastPeak.peak || lastPeak.valley)
            {
                lastPeak.date = candlesticks[count].Date; // Set the date for the last peak
                peakList.Add(lastPeak); // Add the last peak to the list
            }

            // Return the list of peaks and valleys
            return peakList;
        }

        /// <summary>
        /// wrapper function to add all peaks and valley annotations to the chart
        /// </summary>
        public void showAnnotations()
        {
            foreach (Smartcandlestick peak in peakValleyList)
            {
                textAnnotation(peak);
            }

        }

        /// <summary>
        /// create text annotations for peaks and valleys
        /// </summary>
        /// <param name="peak"></param>
        private void textAnnotation(Smartcandlestick peak)
        {
            string text;
            if (peak.peak)
            {
                text = "P";
            }
            else
            {
                text = "V";
            }
            TextAnnotation annotation = new TextAnnotation()
            {
                Text = text,
                AnchorDataPoint = chart1.Series[0].Points[peak.index]
            };
            if (!peak.peak)
            {
                annotation.ForeColor = Color.Green;
            }
            else
            {
                annotation.ForeColor = Color.Red;
            }

            chart1.Annotations.Add(annotation);

        }

        /// <summary>
        /// find all valid waves out of the peakvalley list, indicate if they are up or down
        /// </summary>
        /// <param name="peakList"></param>
        /// <returns></returns>
        public List<Wave> FindValidWaves(List<Smartcandlestick> peakList)
        {
            // Initialize a list to store valid waves
            var waves = new List<Wave>();

            // Loop through the peak list to find potential start points for waves
            for (int i = 0; i < peakList.Count; i++)
            {
                var start = peakList[i]; // Get the start peak or valley

                // Loop through the remaining peaks and valleys to find matching end points for waves
                for (int j = i + 1; j < peakList.Count; j++)
                {
                    bool isValid = true; // Flag to indicate if the wave is valid
                    decimal StartPrice = 0; // Price at the start of the wave
                    decimal EndPrice = 0; // Price at the end of the wave
                    var end = peakList[j]; // Get the end peak or valley
                    bool up = true; // Flag to check if it's an up wave
                    bool down = true; // Flag to check if it's a down wave

                    // Check for down wave (start is a peak, end is a valley)
                    if (start.peak && end.valley)
                    {
                        StartPrice = currentFilter[start.index].High; // Set start price from the peak's high value
                        EndPrice = currentFilter[end.index].Low; // Set end price from the valley's low value
                        up = false; // Set up flag to false since it's a down wave
                        down = true; // Set down flag to true

                        // Check if any candlesticks between the start and end break the validity of the wave
                        for (int k = start.index + 1; k < end.index; k++)
                        {
                            if (currentFilter[k].High > StartPrice || currentFilter[k].Low < EndPrice)
                            {
                                isValid = false; // Mark as invalid if any candlestick breaks the wave
                            }
                        }
                    }
                    // Check for up wave (start is a valley, end is a peak)
                    else if (start.valley && end.peak)
                    {
                        StartPrice = currentFilter[start.index].Low; // Set start price from the valley's low value
                        EndPrice = currentFilter[end.index].High; // Set end price from the peak's high value
                        up = true; // Set up flag to true since it's an up wave
                        down = false; // Set down flag to false

                        // Check if any candlesticks between the start and end break the validity of the wave
                        for (int k = start.index + 1; k < end.index; k++)
                        {
                            if (currentFilter[k].High > EndPrice || currentFilter[k].Low < StartPrice)
                            {
                                isValid = false; // Mark as invalid if any candlestick breaks the wave
                            }
                        }
                    }

                    // If the wave is valid and it's an up wave, add it to the list
                    if (up && isValid && !down)
                    {
                        waves.Add(new Wave
                        {
                            startPrice = StartPrice,
                            endPrice = EndPrice,
                            startIndex = start.index,
                            endIndex = end.index,
                            startDate = start.date,
                            endDate = end.date,
                            up = true, // Indicate it's an up wave
                            down = false, // Indicate it's not a down wave
                            displayDate = start.date.ToShortDateString() + "-" + end.date.ToShortDateString() // Display the date range
                        });
                    }
                    // If the wave is valid and it's a down wave, add it to the list
                    else if (!up && isValid && down)
                    {
                        waves.Add(new Wave
                        {
                            startPrice = StartPrice,
                            endPrice = EndPrice,
                            startIndex = start.index,
                            endIndex = end.index,
                            startDate = start.date,
                            endDate = end.date,
                            up = false, // Indicate it's not an up wave
                            down = true, // Indicate it's a down wave
                            displayDate = start.date.ToShortDateString() + "-" + end.date.ToShortDateString() // Display the date range
                        });
                    }
                }
            }

            // Return the list of valid waves
            return waves;
        }




        /// <summary>
        /// calculate area for rectangle annotation and add it to the chart
        /// </summary>
        /// <param name="wave"></param>
        public void addWaveAnnotations(Wave wave)
        {// Clear any existing annotations from the chart
            chart1.Annotations.Clear();

            // Calculate the start and end index of the wave (with an offset of +1 to adjust for zero-based indexing)
            var startIndex = wave.startIndex + 1;
            var endIndex = wave.endIndex + 1;

            // Calculate the width and height of the rectangle annotation
            // Width is the absolute difference between the start and end indices
            var width = Math.Abs(startIndex - endIndex);

            // Height is the absolute difference between the start and end prices
            var height = Math.Abs((double)wave.endPrice - (double)wave.startPrice);

            // Determine the X and Y coordinates for the rectangle (the lower-left corner of the rectangle)
            double x = Math.Min(startIndex, endIndex); // X is the smaller index (start or end)
            double y = Math.Min((double)wave.startPrice, (double)wave.endPrice); // Y is the smaller price (start or end)

            // Create a rectangle annotation for the chart
            RectangleAnnotation annotation = new RectangleAnnotation
            {
                AxisX = chart1.ChartAreas[0].AxisX, // Set the X axis for the annotation
                AxisY = chart1.ChartAreas[0].AxisY, // Set the Y axis for the annotation
                Width = width, // Set the calculated width
                Height = height, // Set the calculated height
                X = x, // Set the X coordinate
                Y = y, // Set the Y coordinate
                LineWidth = 2, // Set the border line width of the rectangle
                LineColor = Color.Black, // Set the border color of the rectangle to black
                IsSizeAlwaysRelative = false, // Set the size of the rectangle to be fixed (not relative)
            };

            // Set the background color of the rectangle based on the direction of the wave (up or down)
            if (wave.up)
            {
                // If the wave is up, set the rectangle's background color to green with 50% transparency
                annotation.BackColor = Color.FromArgb(50, Color.Green);
            }
            else
            {
                // If the wave is down, set the rectangle's background color to red with 50% transparency
                annotation.BackColor = Color.FromArgb(50, Color.Red);
            }

            // Ensure the annotation is clipped within the chart area
            annotation.ClipToChartArea = chart1.ChartAreas[0].Name;

            // Make the annotation visible
            annotation.Visible = true;

            // Add the created annotation to the chart's annotations collection
            chart1.Annotations.Add(annotation);
        }


        //get all upwaves from the list of all waves
        public List<Wave> getUpWaves(List<Wave> waves)
        {//create a new list of upwaves
            List<Wave> upWaves = new List<Wave>();
            foreach (Wave wave in waves)
            {
                if (wave.up)
                {
                    upWaves.Add(wave);
                }
            }
            return upWaves;
        }

        //get all downwaves from list of all waves
        public List<Wave> getDownWaves(List<Wave> waves)
        {//create a new list of downwaves
            List<Wave> downWaves = new List<Wave>();
            foreach (Wave wave in waves)
            {
                if (wave.down)
                {
                    downWaves.Add(wave);
                }
            }
            return downWaves;
        }


        /// <summary>
        /// Create a line annotation starting at the start of the wave to the end of the wave.
        /// </summary>
        /// <param name="startIndex">The starting index of the wave.</param>
        /// <param name="endIndex">The ending index of the wave.</param>
        /// <param name="startprice">The starting price of the wave.</param>
        /// <param name="endprice">The ending price of the wave.</param>
        public void createLineAnnotation(int startIndex, int endIndex, double startprice, double endprice)
        {
            int width = Math.Abs(startIndex + endIndex);
            double height = Math.Abs(startprice - endprice);
            var area = chart1.ChartAreas["ChartArea_Candlestick"];
            var lineAnnotation = new LineAnnotation()
            {
                AxisX = area.AxisX, // X-axis of the chart
                AxisY = area.AxisY, // Y-axis of the chart
                Name = "diag", // Name of the annotation
                X = startIndex + 1, // X position of the annotation, adjusted for zero-indexing
                Y = startprice, // Y position based on the start price
                Width = width, // Set the calculated width
                Height = -height, // Set the height (negative for descending line)
                LineColor = Color.Green, // Set line color to green
                LineWidth = 2, // Set line width
                IsSizeAlwaysRelative = true, // Size relative to chart area
                ClipToChartArea = area.Name, // Clip annotation to chart area
            };
            chart1.Annotations.Add(lineAnnotation);
        }

        //flag for initial load of listbox
        private bool isInit1 = true;
        private bool isInit2 = true;

        // Handle the selection change event for the "UpWaves" list box
        private void listBox_UpWaves_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Prevent actions during initial load of list box
            if (isInit1)
            {
                isInit1 = false;
                return;
            }

            chart1.Invalidate(); // Invalidate the chart to refresh it
            var wave = listBox_UpWaves.SelectedItem as Wave; // Get the selected wave from the list
            addWaveAnnotations(wave); // Add wave annotations to the chart

            // Set the start and current prices for the wave
            startPrice = (double)wave.startPrice;
            currentPrice = stepPrice = (double)wave.endPrice;

            // Display Fibonacci levels for the wave
            display_FibLevels(startPrice, currentPrice, wave.startIndex, wave.endIndex);
            chart1.Update(); // Update the chart

        }

        private void listBox_DownWaves_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (isInit2)
            {
                isInit2 = false;
                return;
            }
            chart1.Invalidate();
            var wave = listBox_DownWaves.SelectedItem as Wave;
            addWaveAnnotations(wave);
            startPrice = (double)wave.startPrice;
            currentPrice = stepPrice = (double)wave.endPrice;
            display_FibLevels(startPrice, currentPrice, wave.startIndex, wave.endIndex);

            chart1.Update();
        }


        bool mouseDown = false;

        RectangleAnnotation drawnAnnotation = null;
        int waveStart = -1;
        int waveEnd = -1;

        Point startingPoint;
        bool isPeak = false;
        bool isValley = false;

        double startPrice = 0.0;
        private void chart1_MouseDown(object sender, MouseEventArgs e)
        {
            if (candlesticks == null || candlesticks.Count == 0 || currentFilter == null || currentFilter.Count == 0)
            {
               
                return;
            }

            mouseDown = true;
            //clear peak valley annotations once user places mouse down
            chart1.Annotations.Clear();

            var chart = (System.Windows.Forms.DataVisualization.Charting.Chart)sender;
            var chartArea = chart.ChartAreas["ChartArea_Candlestick"];

            double xValue = chartArea.AxisX.PixelPositionToValue(e.X);
            waveStart = (int)Math.Round(xValue);

            //getting proper index for wave start
            waveStart -= 1;
            startingPoint = e.Location;
            
            // removing of margin offsets from the chart area to make sure location is accurate
            var a = chartArea.InnerPlotPosition;
            var b = chartArea.Position;

            var plotX = e.X - chart1.ClientSize.Width * b.X / 100 - chart1.ClientSize.Width * a.X / 100;
            var plotY = e.Y - chart1.ClientSize.Height * b.Y / 100 - chart1.ClientSize.Height * a.Y / 100;

            var x = chartArea.AxisX.PixelPositionToValue(plotX);
            var y = chartArea.AxisY.PixelPositionToValue(plotY);

            //check if the starting candlestick is a peak or a valley
            foreach (var peak in peakValleyList)
            {
                if (peak.index == waveStart)
                {
                    if (peak.peak)
                    {
                        isPeak = true;

                    }
                    else if (peak.valley)
                    {
                        isValley = true;
                    }
                }
            }
            if (!(isPeak || isValley))
            {
                MessageBox.Show($"Wave must start at peak or valley: Start :{waveStart}", "invalid");
                mouseDown = false;
                return;
            }
            //choose start price as either the high or low depending on peak or valley
            startPrice = (isPeak) ? (double)currentFilter[waveStart].High : (double)currentFilter[waveStart].Low;
            y = startPrice;
            drawnAnnotation = new RectangleAnnotation
            {//create a rectangle annotation
                Name = "drawnRectangle",
                AxisX = chartArea.AxisX,
                AxisY = chartArea.AxisY,
                LineColor = Color.Blue,
                LineWidth = 2,
                BackColor = Color.FromArgb(50, Color.Blue),
                ClipToChartArea = chartArea.Name,
                X = x,
                Y = startPrice,
                Width = 0,
                Height = 0,
                IsSizeAlwaysRelative = false,
            };

            chart1.Annotations.Add(drawnAnnotation);
        }

        double currentPrice = 0.0;
        /// <summary>
        /// draw rectangle as the user drags the mouse
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void chart1_MouseMove(object sender, MouseEventArgs e)
        {
            if (candlesticks == null || candlesticks.Count == 0 || currentFilter == null || currentFilter.Count == 0)
            {
                
                return;
            }

            //if mouse is not down, or drawn annotation wasnt initialized, return
            if (!mouseDown || drawnAnnotation ==null)
            {
                return;
            }
            var chart = (System.Windows.Forms.DataVisualization.Charting.Chart)sender;
            var chartArea = chart.ChartAreas["ChartArea_Candlestick"];
            var currentPoint = e.Location;
            double x0 = chartArea.AxisX.PixelPositionToValue(startingPoint.X);
            double y0 = startPrice;

            //double y0 = chartArea.AxisY.PixelPositionToValue(startingPoint.Y);
            double x1 = chartArea.AxisX.PixelPositionToValue(currentPoint.X);
            double y1 = chartArea.AxisY.PixelPositionToValue(currentPoint.Y);



            var dy = y1 - y0;
            if (drawnAnnotation != null)
            {//calculate the width and height of the rectangle
                if (x1 >= x0)
                {
                    drawnAnnotation.X = x0;
                    drawnAnnotation.Width = x1 - x0;
                }
                else
                {//if the x1 is less than x0, set the width to be negative
                    drawnAnnotation.X = x1;
                    drawnAnnotation.Width = x0 - x1;
                }
                if (dy >= 0)
                {// if the y1 is greater than y0, set the height to be positive
                    drawnAnnotation.Y = y0;
                    drawnAnnotation.Height = dy;

                }
                else
                {//if the y1 is less than y0, set the height to be negative
                    drawnAnnotation.Y = y1;
                    drawnAnnotation.Height = -(dy);
                }
            }

            //calculate the current end candlestick index
            waveEnd = (!(drawnAnnotation == null)) ? (int)Math.Round(drawnAnnotation.Width + waveStart) : -1;

            //calculate current price depending on up/down wave
            currentPrice = (dy >= 0) ? startPrice + drawnAnnotation.Height : startPrice - drawnAnnotation.Height;

            //clear chart if current wave is not valid
            chart1.Annotations.Clear();
            chartArea.AxisY.StripLines.Clear();

            //draw wave if it is valid
            if (determineValidWave(waveStart, waveEnd))
            {
                display_FibLevels(startPrice, currentPrice, waveStart, waveEnd);
                
                chart1.Annotations.Add(drawnAnnotation);
            }
        }
        /// <summary>
        /// mouse up event, check if the wave is valid and add it to the chart
        /// mouse dowun event, check if the wave is valid and add it to the chart
        private void chart1_MouseUp(object sender, MouseEventArgs e)
        {
            if (candlesticks == null || candlesticks.Count == 0 || currentFilter == null || currentFilter.Count == 0)
            {
                
                return;
            }

            mouseDown = false;
            var chart = (System.Windows.Forms.DataVisualization.Charting.Chart)sender;
            var chartArea = chart.ChartAreas["ChartArea_Candlestick"];

            waveEnd = (drawnAnnotation != null) ? (int)Math.Round(drawnAnnotation.Width + waveStart) : 0;
            if (!determineValidWave(waveStart, waveEnd))
            {
                MessageBox.Show("Ended on an invalid wave, a valid wave will appear when you are in the right position", "Invalid Wave");
                chart.Annotations.Clear();
                chartArea.AxisY.StripLines.Clear();

            }
            else
            {//if the wave is valid, add it to the chart
                MessageBox.Show($"Wave selected: Start = {waveStart}, End = {waveEnd}, start price: {startPrice}, end price: {currentPrice}", "Debug Info");

                display_FibLevels(startPrice, (double)currentPrice, waveStart, waveEnd);
                createLineAnnotation(waveStart, waveEnd, startPrice, currentPrice);

                chart1.Annotations.Remove(drawnAnnotation);
                chart1.Annotations.Add(drawnAnnotation);
            }
        }


        List<double> levels = new List<double>();
        /// <summary>
        /// calculate fibonacci levels given the current starting and end price, add line annotations to represent them
        /// </summary>
        /// <param name="startprice"></param>
        /// <param name="endPrice"></param>
        private void display_FibLevels(double startprice, double endPrice, int waveStart, int waveEnd)
        {
            //calculate range and margin
            var range = Math.Abs(endPrice - startprice);
            var margin = range * 0.01;
            var area = chart1.ChartAreas["ChartArea_Candlestick"];
            area.AxisY.StripLines.Clear();

            //clear previous line annotations if there were any
            var lines = chart1.Annotations.OfType<LineAnnotation>().ToList();
            if (lines.Count > 0)
            {
                foreach (var line in lines)
                {
                    chart1.Annotations.Remove(line);
                }
            }

            //delete existing text annotations for fib tags
            var existingFibAnn = chart1.Annotations.OfType<TextAnnotation>().Where(a => a.Tag?.ToString() == "fib").ToList();
            if (existingFibAnn.Count > 0)
            {
                foreach (var ann in existingFibAnn) { chart1.Annotations.Remove(ann); }
            }
            double[] fib_percents = { 0d, 0.236d, 0.382d, 0.5d, 0.618d, 0.764d, 1d };

            levels?.Clear();
            int i = fib_percents.Count() -1;
            double x0 = chart1.Series[0].Points[waveStart].XValue;
            double x1 = chart1.Series[0].Points[waveEnd].XValue;
            double width = x1 - x0;   

            //for each fibonacci level, create a horizontal line annotation at that level
            foreach (var percent in fib_percents)
            {
                double level = 0;
                if (startprice <= endPrice)
                {
                    level = startprice + (range * percent);
                }
                else
                {
                    level = startprice - (range * percent);
                }

                var strip = new StripLine
                {
                    IntervalOffset = level,
                    BorderColor = Color.Purple,
                    BorderWidth = 2,
                    BorderDashStyle = ChartDashStyle.Solid,
                    BackColor = Color.Transparent,
                };
                area.AxisY.StripLines.Add(strip);

                //add labels (text annotation) for each fib level
                var textAnn = new TextAnnotation()
                {
                    Name = $"fib {i}",
                    AxisX = area.AxisX,
                    AxisY = area.AxisY,
                    Tag = "fib",
                    Text = $"{fib_percents[i] * 100}%",
                    AnchorX = waveEnd,
                    AnchorY = level,
                };
                chart1.Annotations.Add(textAnn);
                i--;
            }

            
            double leftX = waveStart;

            foreach (var percent in fib_percents)
            {
                levels.Add(startprice + (range * percent));
            }
            //update confirmation label
            label_Confirmations.Text = calculateConfirmations(margin, levels, waveStart, waveEnd).ToString();

        }

        List<Tuple<int, double>> confirmations;

        private int calculateConfirmations(double margin, List<double> fib_levels, int waveStart, int waveEnd)
        {
            //if list is null create new list, otherwise clear it
            if (confirmations == null)
            {
                confirmations = new List<Tuple<int, double>>();
            }
            else
            {//clear the list
                confirmations.Clear();
            }
            //iterate through each candlestick and each fibonacci level to see if any values are within range.
            int count = 0;
            for (int i = waveStart; i <= waveEnd; i++)
            {
                double high = (double)currentFilter[i].High;
                double low = (double)currentFilter[i].Low;
                double open = (double)currentFilter[i].Open;
                double close = (double)currentFilter[i].Close;
                foreach (var level in fib_levels)
                {
                    //check OHLC is within 1% of fib level
                    if (high >= level - margin && high <= level + margin) {
                        count++;
                        var conf = Tuple.Create(i, high);
                        confirmations.Add(conf); }

                    else if (low >= level - margin && low <= level + margin) {
                        count++;
                        var conf = Tuple.Create(i, low);
                        confirmations.Add(conf);
                    }

                    else if (close >= level - margin && close <= level + margin) {
                        count++;
                        var conf = Tuple.Create(i, close);
                        confirmations.Add(conf); ; }

                    else if (open >= level - margin && open <= level + margin) {
                        count++;
                        var conf = Tuple.Create(i, open);
                        confirmations.Add(conf);
                    }

                }

            }
            //if there are confirmations, draw them
            if (confirmations != null)
            {   //draw the confirmation annotations
                confirmationAnnotations(confirmations);
            }
            return count;
        }

        /// <summary>
        /// Draw the confirmation annotations 
        /// </summary>
        /// <param name="confirmations"></param>
        private void confirmationAnnotations(List<Tuple<int, double>> confirmations)
        {
            //remove existing annotations
            var existingConfirmations = chart1.Annotations.OfType<TextAnnotation>().Where(a => a.Tag?.ToString() == "confirmation").ToList();
            if (confirmations.Count > 0)
            {
                foreach (var ann in existingConfirmations)
                {
                    chart1.Annotations.Remove(ann);
                }
            }

            //make a text annotation for each confirmation found
            foreach (var value in confirmations)
            {
                var annotation = new TextAnnotation()
                {
                    Tag = "confirmations",
                    AxisX = chart1.ChartAreas["ChartArea_Candlestick"].AxisX,
                    AxisY = chart1.ChartAreas["ChartArea_Candlestick"].AxisY,

                    AnchorX = value.Item1 + 1,
                    AnchorY = value.Item2,
                    Text = "C",

                };
                chart1.Annotations.Add(annotation);
            }

        }
        double stepPrice = 0.0;
        private void button_Simulate_Click(object sender, EventArgs e)
        {
            if (candlesticks == null || candlesticks.Count == 0 || currentFilter == null || currentFilter.Count == 0)
            {
                
                return;
            }


            //turn on timer control
            stepPrice = currentPrice;
            timer_Simulate.Enabled = !timer_Simulate.Enabled;

            if (timer_Simulate.Enabled)
            {
                button_Simulate.Text = "Stop";
            }
            else
            {
                button_Simulate.Text = "Start";
            }
        }
        double stepSize = 0.20;
        bool isInit= false;
        private void button_Plus_Click(object sender, EventArgs e)
        {
            if (candlesticks == null || candlesticks.Count == 0 || currentFilter == null || currentFilter.Count == 0)
            {
               
                return;
            }

            //call simulate tick function with up being true
            if (!isInit)
            {
                stepPrice = currentPrice;
                isInit = true;
            }
            simulateTick(true, chart1.Annotations.OfType<RectangleAnnotation>().ToList()[0]);
        }

        private void button_Clear_Click(object sender, EventArgs e)
        {
            
        }

        private void timer_Simulate_Tick(object sender, EventArgs e)
        {
            if (candlesticks == null || candlesticks.Count == 0 || currentFilter == null || currentFilter.Count == 0)
            {
               
                return;
            }

            simulateTick(true, chart1.Annotations.OfType<RectangleAnnotation>().ToList()[0]);
        }

        private void button_Minus_Click(object sender, EventArgs e)
        {
            if (candlesticks == null || candlesticks.Count == 0 || currentFilter == null || currentFilter.Count == 0)
            {
                
                return;
            }

            //call simulate tick function with up being false
            if (!isInit)
            {
                stepPrice = currentPrice;
                isInit = true;
            }
            simulateTick(false, chart1.Annotations.OfType<RectangleAnnotation>().ToList()[0]);
        }

        /// <summary>
        /// function that increments a waves end price in ticks
        /// </summary>
        /// <param name="up"></param>
        /// <param name="wave"></param>
        private void simulateTick(bool up, RectangleAnnotation wave)
        {
            if (wave == null || currentFilter == null || currentFilter.Count == 0) return;  // Safety check

            // Ensure waveStart and waveEnd are within valid range
            if (waveStart < 0 || waveStart >= currentFilter.Count || waveEnd < 0 || waveEnd >= currentFilter.Count)
            {
                return; // Don't do anything if indices are invalid
            }

            double range = Math.Abs(currentPrice - startPrice);
            stepPrice += up ? stepSize : -stepSize;
            double max = currentPrice + (range * 0.20);
            double min = currentPrice - (range * 0.20);

            if (stepPrice > max) stepPrice = min;
            wave.Height = Math.Abs(startPrice - stepPrice);
            display_FibLevels(startPrice, stepPrice, waveStart, waveEnd);
        }

        /// <summary>
        /// determine whether there is a valid wave between the two index given
        /// </summary>
        /// <param name="startIndex"></param>
        /// <param name="endIndex"></param>
        /// <returns></returns>
        private bool determineValidWave(int startIndex, int endIndex)
        {//checking to see if its valid 
            bool isValid = true;

            if (isPeak)
            {
                for (int i = startIndex + 1; i < endIndex; i++)
                {
                    if ((double)currentFilter[i].High > startPrice || (double)currentFilter[i].Low < currentPrice) { isValid = false; break; }
                }
            }
            else
            {//if valley
                for (int i = startIndex + 1; i < endIndex; i++)
                {
                    if ((double)currentFilter[i].Low < startPrice || (double)currentFilter[i].High > currentPrice) { isValid = false; break; }
                }
            }

            return isValid;
        }//end of determineValidWave

        private void button_StepSizeChanged_Click(object sender, EventArgs e)
        {//parsing the step size from the text box
            stepSize = double.Parse(textBox_StepSize.Text);
        }

        private void dateTimePicker_StartDate_ValueChanged(object sender, EventArgs e)
        {

        }

        private void label1_Click(object sender, EventArgs e)
        {

        }

        private void label4_Click(object sender, EventArgs e)
        {

        }

        private void label3_Click(object sender, EventArgs e)
        {

        }
    }
}
