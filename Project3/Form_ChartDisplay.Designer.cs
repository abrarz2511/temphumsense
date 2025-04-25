namespace Project3
{
    partial class Form_ChartDisplay
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.Windows.Forms.DataVisualization.Charting.ChartArea chartArea2 = new System.Windows.Forms.DataVisualization.Charting.ChartArea();
            System.Windows.Forms.DataVisualization.Charting.Legend legend2 = new System.Windows.Forms.DataVisualization.Charting.Legend();
            System.Windows.Forms.DataVisualization.Charting.Series series2 = new System.Windows.Forms.DataVisualization.Charting.Series();
            this.chart1 = new System.Windows.Forms.DataVisualization.Charting.Chart();
            this.button_update = new System.Windows.Forms.Button();
            this.dateTimePicker_StartDate = new System.Windows.Forms.DateTimePicker();
            this.dateTimePicker_EndDate = new System.Windows.Forms.DateTimePicker();
            this.hScrollBar_Margin = new System.Windows.Forms.HScrollBar();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.listBox_UpWaves = new System.Windows.Forms.ListBox();
            this.waveBindingSource = new System.Windows.Forms.BindingSource(this.components);
            this.listBox_DownWaves = new System.Windows.Forms.ListBox();
            this.label_ConfLabe = new System.Windows.Forms.Label();
            this.label_Confirmations = new System.Windows.Forms.Label();
            this.button_Simulate = new System.Windows.Forms.Button();
            this.button_Plus = new System.Windows.Forms.Button();
            this.button_Minus = new System.Windows.Forms.Button();
            this.timer_Simulate = new System.Windows.Forms.Timer(this.components);
            this.label3 = new System.Windows.Forms.Label();
            this.textBox_StepSize = new System.Windows.Forms.TextBox();
            this.button_StepSizeChanged = new System.Windows.Forms.Button();
            this.openFileDialog_LoadTicker = new System.Windows.Forms.OpenFileDialog();
            this.button_LoadTicker = new System.Windows.Forms.Button();
            this.label4 = new System.Windows.Forms.Label();
            this.label5 = new System.Windows.Forms.Label();
            this.label_Margin = new System.Windows.Forms.Label();
            ((System.ComponentModel.ISupportInitialize)(this.chart1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.waveBindingSource)).BeginInit();
            this.SuspendLayout();
            // 
            // chart1
            // 
            chartArea2.Name = "ChartArea_Candlestick";
            this.chart1.ChartAreas.Add(chartArea2);
            this.chart1.Dock = System.Windows.Forms.DockStyle.Top;
            legend2.Name = "Legend1";
            this.chart1.Legends.Add(legend2);
            this.chart1.Location = new System.Drawing.Point(0, 0);
            this.chart1.Margin = new System.Windows.Forms.Padding(2);
            this.chart1.Name = "chart1";
            series2.ChartArea = "ChartArea_Candlestick";
            series2.ChartType = System.Windows.Forms.DataVisualization.Charting.SeriesChartType.Candlestick;
            series2.CustomProperties = "PriceDownColor=Red, PriceUpColor=Green";
            series2.IsXValueIndexed = true;
            series2.Legend = "Legend1";
            series2.Name = "Candlesticks";
            series2.XValueMember = "Date";
            series2.XValueType = System.Windows.Forms.DataVisualization.Charting.ChartValueType.Date;
            series2.YValueMembers = "High, Low, Open, Close";
            series2.YValuesPerPoint = 4;
            this.chart1.Series.Add(series2);
            this.chart1.Size = new System.Drawing.Size(962, 306);
            this.chart1.TabIndex = 0;
            this.chart1.Text = "chart1";
            this.chart1.MouseDown += new System.Windows.Forms.MouseEventHandler(this.chart1_MouseDown);
            this.chart1.MouseMove += new System.Windows.Forms.MouseEventHandler(this.chart1_MouseMove);
            this.chart1.MouseUp += new System.Windows.Forms.MouseEventHandler(this.chart1_MouseUp);
            // 
            // button_update
            // 
            this.button_update.Location = new System.Drawing.Point(389, 375);
            this.button_update.Margin = new System.Windows.Forms.Padding(2);
            this.button_update.Name = "button_update";
            this.button_update.Size = new System.Drawing.Size(71, 22);
            this.button_update.TabIndex = 1;
            this.button_update.Text = "Update";
            this.button_update.UseVisualStyleBackColor = true;
            this.button_update.Click += new System.EventHandler(this.button_Refresh_Click);
            // 
            // dateTimePicker_StartDate
            // 
            this.dateTimePicker_StartDate.Location = new System.Drawing.Point(135, 366);
            this.dateTimePicker_StartDate.Margin = new System.Windows.Forms.Padding(2);
            this.dateTimePicker_StartDate.Name = "dateTimePicker_StartDate";
            this.dateTimePicker_StartDate.Size = new System.Drawing.Size(151, 20);
            this.dateTimePicker_StartDate.TabIndex = 2;
            this.dateTimePicker_StartDate.ValueChanged += new System.EventHandler(this.dateTimePicker_StartDate_ValueChanged);
            // 
            // dateTimePicker_EndDate
            // 
            this.dateTimePicker_EndDate.Location = new System.Drawing.Point(135, 401);
            this.dateTimePicker_EndDate.Margin = new System.Windows.Forms.Padding(2);
            this.dateTimePicker_EndDate.Name = "dateTimePicker_EndDate";
            this.dateTimePicker_EndDate.Size = new System.Drawing.Size(151, 20);
            this.dateTimePicker_EndDate.TabIndex = 3;
            // 
            // hScrollBar_Margin
            // 
            this.hScrollBar_Margin.LargeChange = 1;
            this.hScrollBar_Margin.Location = new System.Drawing.Point(54, 322);
            this.hScrollBar_Margin.Maximum = 4;
            this.hScrollBar_Margin.Minimum = 1;
            this.hScrollBar_Margin.Name = "hScrollBar_Margin";
            this.hScrollBar_Margin.Size = new System.Drawing.Size(800, 21);
            this.hScrollBar_Margin.TabIndex = 4;
            this.hScrollBar_Margin.Value = 1;
            this.hScrollBar_Margin.Scroll += new System.Windows.Forms.ScrollEventHandler(this.hScrollBar1_Scroll);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(601, 472);
            this.label1.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(58, 13);
            this.label1.TabIndex = 8;
            this.label1.Text = "Up Waves";
            this.label1.Click += new System.EventHandler(this.label1_Click);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(715, 473);
            this.label2.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(72, 13);
            this.label2.TabIndex = 9;
            this.label2.Text = "Down Waves";
            // 
            // listBox_UpWaves
            // 
            this.listBox_UpWaves.DataSource = this.waveBindingSource;
            this.listBox_UpWaves.DisplayMember = "displayDate";
            this.listBox_UpWaves.FormattingEnabled = true;
            this.listBox_UpWaves.Location = new System.Drawing.Point(572, 401);
            this.listBox_UpWaves.Margin = new System.Windows.Forms.Padding(2);
            this.listBox_UpWaves.Name = "listBox_UpWaves";
            this.listBox_UpWaves.Size = new System.Drawing.Size(122, 69);
            this.listBox_UpWaves.TabIndex = 10;
            this.listBox_UpWaves.SelectedIndexChanged += new System.EventHandler(this.listBox_UpWaves_SelectedIndexChanged);
            // 
            // waveBindingSource
            // 
            this.waveBindingSource.DataSource = typeof(Project3.Wave);
            // 
            // listBox_DownWaves
            // 
            this.listBox_DownWaves.DataSource = this.waveBindingSource;
            this.listBox_DownWaves.DisplayMember = "displayDate";
            this.listBox_DownWaves.FormattingEnabled = true;
            this.listBox_DownWaves.Location = new System.Drawing.Point(698, 402);
            this.listBox_DownWaves.Margin = new System.Windows.Forms.Padding(2);
            this.listBox_DownWaves.Name = "listBox_DownWaves";
            this.listBox_DownWaves.Size = new System.Drawing.Size(126, 69);
            this.listBox_DownWaves.TabIndex = 11;
            this.listBox_DownWaves.SelectedIndexChanged += new System.EventHandler(this.listBox_DownWaves_SelectedIndexChanged);
            // 
            // label_ConfLabe
            // 
            this.label_ConfLabe.AutoSize = true;
            this.label_ConfLabe.Location = new System.Drawing.Point(658, 350);
            this.label_ConfLabe.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label_ConfLabe.Name = "label_ConfLabe";
            this.label_ConfLabe.Size = new System.Drawing.Size(70, 13);
            this.label_ConfLabe.TabIndex = 12;
            this.label_ConfLabe.Text = "Confirmations";
            // 
            // label_Confirmations
            // 
            this.label_Confirmations.AutoSize = true;
            this.label_Confirmations.Location = new System.Drawing.Point(681, 366);
            this.label_Confirmations.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label_Confirmations.Name = "label_Confirmations";
            this.label_Confirmations.Size = new System.Drawing.Size(13, 13);
            this.label_Confirmations.TabIndex = 13;
            this.label_Confirmations.Text = "0";
            // 
            // button_Simulate
            // 
            this.button_Simulate.Location = new System.Drawing.Point(747, 350);
            this.button_Simulate.Margin = new System.Windows.Forms.Padding(2);
            this.button_Simulate.Name = "button_Simulate";
            this.button_Simulate.Size = new System.Drawing.Size(77, 43);
            this.button_Simulate.TabIndex = 14;
            this.button_Simulate.Text = "Start";
            this.button_Simulate.UseVisualStyleBackColor = true;
            this.button_Simulate.Click += new System.EventHandler(this.button_Simulate_Click);
            // 
            // button_Plus
            // 
            this.button_Plus.Location = new System.Drawing.Point(572, 350);
            this.button_Plus.Margin = new System.Windows.Forms.Padding(2);
            this.button_Plus.Name = "button_Plus";
            this.button_Plus.Size = new System.Drawing.Size(55, 21);
            this.button_Plus.TabIndex = 15;
            this.button_Plus.Text = "+";
            this.button_Plus.UseVisualStyleBackColor = true;
            this.button_Plus.Click += new System.EventHandler(this.button_Plus_Click);
            // 
            // button_Minus
            // 
            this.button_Minus.Location = new System.Drawing.Point(572, 375);
            this.button_Minus.Margin = new System.Windows.Forms.Padding(2);
            this.button_Minus.Name = "button_Minus";
            this.button_Minus.Size = new System.Drawing.Size(55, 22);
            this.button_Minus.TabIndex = 16;
            this.button_Minus.Text = "-";
            this.button_Minus.UseVisualStyleBackColor = true;
            this.button_Minus.Click += new System.EventHandler(this.button_Minus_Click);
            // 
            // timer_Simulate
            // 
            this.timer_Simulate.Interval = 500;
            this.timer_Simulate.Tick += new System.EventHandler(this.timer_Simulate_Tick);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(51, 442);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(73, 13);
            this.label3.TabIndex = 17;
            this.label3.Text = " Step Size: ($)";
            this.label3.Click += new System.EventHandler(this.label3_Click);
            // 
            // textBox_StepSize
            // 
            this.textBox_StepSize.Location = new System.Drawing.Point(130, 438);
            this.textBox_StepSize.Name = "textBox_StepSize";
            this.textBox_StepSize.Size = new System.Drawing.Size(100, 20);
            this.textBox_StepSize.TabIndex = 18;
            this.textBox_StepSize.Tag = "";
            this.textBox_StepSize.Text = "0.20";
            // 
            // button_StepSizeChanged
            // 
            this.button_StepSizeChanged.Location = new System.Drawing.Point(239, 438);
            this.button_StepSizeChanged.Name = "button_StepSizeChanged";
            this.button_StepSizeChanged.Size = new System.Drawing.Size(47, 23);
            this.button_StepSizeChanged.TabIndex = 19;
            this.button_StepSizeChanged.Text = "Apply";
            this.button_StepSizeChanged.UseVisualStyleBackColor = true;
            this.button_StepSizeChanged.Click += new System.EventHandler(this.button_StepSizeChanged_Click);
            // 
            // openFileDialog_LoadTicker
            // 
            this.openFileDialog_LoadTicker.DefaultExt = "CSV";
            this.openFileDialog_LoadTicker.FileName = "ABBV-Day";
            this.openFileDialog_LoadTicker.Filter = "All|*.csv|Month|*-Month.csv|Week|*-Week.csv|Day|*-Day.csv";
            this.openFileDialog_LoadTicker.Multiselect = true;
            this.openFileDialog_LoadTicker.ReadOnlyChecked = true;
            this.openFileDialog_LoadTicker.ShowReadOnly = true;
            this.openFileDialog_LoadTicker.FileOk += new System.ComponentModel.CancelEventHandler(this.openFileDialog_LoadTicker_FileOk);
            // 
            // button_LoadTicker
            // 
            this.button_LoadTicker.Location = new System.Drawing.Point(389, 434);
            this.button_LoadTicker.Margin = new System.Windows.Forms.Padding(2);
            this.button_LoadTicker.Name = "button_LoadTicker";
            this.button_LoadTicker.Size = new System.Drawing.Size(71, 26);
            this.button_LoadTicker.TabIndex = 0;
            this.button_LoadTicker.Text = "Load Ticker";
            this.button_LoadTicker.Click += new System.EventHandler(this.button_LoadTicker_Click);
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(69, 372);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(55, 13);
            this.label4.TabIndex = 20;
            this.label4.Text = "Start Date";
            this.label4.Click += new System.EventHandler(this.label4_Click);
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(69, 408);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(52, 13);
            this.label5.TabIndex = 21;
            this.label5.Text = "End Date";
            // 
            // label_Margin
            // 
            this.label_Margin.AutoSize = true;
            this.label_Margin.Location = new System.Drawing.Point(39, 330);
            this.label_Margin.Margin = new System.Windows.Forms.Padding(2, 0, 2, 0);
            this.label_Margin.Name = "label_Margin";
            this.label_Margin.Size = new System.Drawing.Size(13, 13);
            this.label_Margin.TabIndex = 5;
            this.label_Margin.Text = "1";
            // 
            // Form_ChartDisplay
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.ActiveBorder;
            this.ClientSize = new System.Drawing.Size(962, 574);
            this.Controls.Add(this.label5);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.button_LoadTicker);
            this.Controls.Add(this.button_StepSizeChanged);
            this.Controls.Add(this.textBox_StepSize);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.button_Minus);
            this.Controls.Add(this.button_Plus);
            this.Controls.Add(this.button_Simulate);
            this.Controls.Add(this.label_Confirmations);
            this.Controls.Add(this.label_ConfLabe);
            this.Controls.Add(this.listBox_DownWaves);
            this.Controls.Add(this.listBox_UpWaves);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.label_Margin);
            this.Controls.Add(this.hScrollBar_Margin);
            this.Controls.Add(this.dateTimePicker_EndDate);
            this.Controls.Add(this.dateTimePicker_StartDate);
            this.Controls.Add(this.button_update);
            this.Controls.Add(this.chart1);
            this.Margin = new System.Windows.Forms.Padding(2);
            this.Name = "Form_ChartDisplay";
            this.Text = "Form_ChartDisplay";
            ((System.ComponentModel.ISupportInitialize)(this.chart1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.waveBindingSource)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataVisualization.Charting.Chart chart1;
        private System.Windows.Forms.Button button_update;
        private System.Windows.Forms.DateTimePicker dateTimePicker_StartDate;
        private System.Windows.Forms.DateTimePicker dateTimePicker_EndDate;
        private System.Windows.Forms.HScrollBar hScrollBar_Margin;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.ListBox listBox_DownWaves;
        private System.Windows.Forms.BindingSource waveBindingSource;
        private System.Windows.Forms.ListBox listBox_UpWaves;
        private System.Windows.Forms.Label label_ConfLabe;
        private System.Windows.Forms.Label label_Confirmations;
        private System.Windows.Forms.Button button_Simulate;
        private System.Windows.Forms.Button button_Plus;
        private System.Windows.Forms.Button button_Minus;
        private System.Windows.Forms.Timer timer_Simulate;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox textBox_StepSize;
        private System.Windows.Forms.Button button_StepSizeChanged;
        private System.Windows.Forms.OpenFileDialog openFileDialog_LoadTicker;
        private System.Windows.Forms.Button button_LoadTicker;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.Label label_Margin;
    }
}