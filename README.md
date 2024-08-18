# Calcium Imaging Signal Filtering

This repository contains a MATLAB function for filtering calcium imaging signals based on their correlation with a reference signal, typically from the best detected cell. This method is useful for isolating significant cellular activity by enhancing portions of the signal that match a reference pattern extracted from the most prominent cell in the dataset.

## Features
- **Signal Filtering**: Filters signals from multiple cells based on their similarity to a reference signal.
- **Correlation-Based Analysis**: Utilizes correlation with a reference pattern to retain relevant signal segments.
- **Peak Detection**: Optional peak detection feature to further refine signal filtering.
- **Adjustable Parameters**: Flexible parameters for correlation window size, peak detection sensitivity, and pattern extraction.

## Function Overview
The main function, `filter_calcium_signal`, processes calcium imaging data to retain parts of each cell's signal that are correlated with a reference signal. It offers the ability to adjust several parameters to tailor the filtering process to your specific data and analysis needs.

### Steps:
1. **Peak Detection in Reference Signal**:
   - The function first detects peaks in the `ref_signal` (Reference signal, typically from the best detected cell) using the Pan-Tompkins algorithm. This algorithm is well-suited for calcium imaging data due to the similar transient spike patterns observed, analogous to QRS complexes in ECG signals.
   
2. **Pattern Extraction**:
   - From the detected peaks in the `ref_signal`, a window of data around each peak (defined by `pattern_len`: Length of the pattern used for correlation) is extracted.
   - These segments are averaged to create a `pattern_template` that represents the typical waveform feature in the reference signal.

3. **Signal Correlation and Filtering**:
   - The input signal (`signal_data`: Matrix of calcium signals, where each row represents a cell) is then processed. This signal can be the `ref_signal` itself or any other signal believed to have the same pattern as the reference. In calcium imaging from a single rat, it is often assumed that all cells can exhibit similar patterns.
   - Peaks in the `signal_data` are detected using the Pan-Tompkins algorithm.
   - For each segment of the `signal_data` centered around these peaks, the function calculates the correlation with the `pattern_template` using a window of size `corr_window_size` (Window size for correlation calculation).
   - Only those segments with a correlation above `corr_threshold` (Threshold for correlation values to be considered significant) are considered significant.
   - Additionally, if `consider_peak` (Boolean flag to include peak detection in filtering) is set to 1, the function also checks if these peaks exceed the mean of all detected peaks in the `signal_data` (to ensure significant events are retained).

4. **Final Signal Estimation**:
   - Based on both the correlation with the `pattern_template` and the peak thresholding (if `consider_peak` is enabled), portions of the signal estimated to contain relevant data are selected and retained.
   - Other parts of the signal that do not meet these criteria are attenuated (weakened), resulting in the `filtered_signals` output.

### Input Parameters:
- `signal_data`: Matrix of calcium signals, where each row represents a cell.
- `ref_signal`: Reference signal, typically from the best detected cell.
- `consider_peak`: Boolean flag (default = 1) to include peak detection in filtering.
- `corr_window_size`: Window size for correlation calculation (default = 40).
- `peak_window_size`: Window size around detected peaks for filtering (default = 10).
- `corr_threshold`: Threshold for correlation values to be considered significant (default = 0.8).
- `fs`: Sampling frequency of the calcium imaging data (default = 1000).
- `pattern_len`: Length of the pattern used for correlation (default = 50).

### Output:
- `filtered_signals`: A matrix of filtered signals, corresponding to the input `signal_data`, with non-relevant portions attenuated.

## ECG and Calcium Imaging Analogy
- **ECG**: The peaks and troughs in the ECG signal represent electrical events like depolarization and repolarization in the heart's cells. These events are crucial for the mechanical contraction of the heart.
- **Calcium Imaging**: Similarly, in calcium imaging, the signal rises and falls with neuronal activity. When a neuron fires (action potential), calcium influx occurs, causing a peak in the signal. This is analogous to the peaks seen in the ECG corresponding to the heart’s electrical activity.

By leveraging the Pan-Tompkins algorithm, this tool can reliably identify these transient events (peaks) in calcium signals, enabling accurate extraction and filtering of significant signal segments. The robust nature of this algorithm makes it well-suited for handling the noisy and varied nature of biological data, such as calcium imaging.

## Use Case
This tool is particularly useful for researchers analyzing calcium imaging data who wish to focus on signal segments that are most relevant to a reference pattern. By filtering signals from other cells based on their correlation with the best detected cell, this approach helps in reducing noise and highlighting important cellular events.

## Example Usage
```matlab
% Example data
data.temporal = ...; % Matrix of calcium signals where each row represents a cell

% Define the list of very noisy cells (e.g., indices of noisy cells)
very_noisy_cells = [];

% Define the length of the list (assuming 40 as the maximum index)
list_length = size(data.temporal, 1);

% Create an array of ones with the specified length
result_list_very_noisy_cells = ones(1, list_length);

% Set the elements at the indices specified in very_noisy_cells to zero
result_list_very_noisy_cells(very_noisy_cells) = 0;

% Create a copy of the original signals
data.temporal_copy = data.temporal;

% Filter each cell's signal based on the reference signal (first cell)
fprintf("Denoising ...\n")
for cell_i_counter = 1:size(data.temporal, 1)
    data.temporal(cell_i_counter, :) = filter_calcium_signal(data.temporal(cell_i_counter, :), data.temporal(1, :), result_list_very_noisy_cells(cell_i_counter));
end
fprintf("100%%\n")
```

## Installation
Simply clone the repository and add the MATLAB files to your project:

```bash
git clone https://github.com/yourusername/calcium-imaging-filter.git
```

## Contributions
Contributions are welcome! Please submit issues or pull requests to help improve this tool.
