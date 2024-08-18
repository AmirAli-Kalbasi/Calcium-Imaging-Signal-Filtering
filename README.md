# Calcium Imaging Signal Filtering

This repository contains a MATLAB function for filtering calcium imaging signals based on their correlation with a reference signal, typically from the best detected cell. This method is useful for isolating significant cellular activity by enhancing portions of the signal that match a reference pattern extracted from the most prominent cell in the dataset.

## Table of Contents

- [Features](#Features)
- [Function Overview](#Function_Overview)
- [Algorithm Overview](#Algorithm_Overview)
  - [Steps](#Steps)
  - [Parameters](#Parameters)
  - [Output](#Output)
  - [Use Case](#Use_Case)
  - [Example](#Example)
  - [Installation](#Installation)

## Features
- **Signal Filtering**: Filters signals from multiple cells based on their similarity to a reference signal.
- **Correlation-Based Analysis**: Utilizes correlation with a reference pattern to retain relevant signal segments.
- **Peak Detection**: Optional peak detection feature to further refine signal filtering.
- **Adjustable Parameters**: Flexible parameters for correlation window size, peak detection sensitivity, and pattern extraction.

## Function_Overview
The main function, `filter_calcium_signal`, processes calcium imaging data to retain parts of each cell's signal that are correlated with a reference signal. It offers the ability to adjust several parameters to tailor the filtering process to your specific data and analysis needs.

[View the code](https://github.com/AmirAli-Kalbasi/Calcium-Imaging-Signal-Filtering/blob/main/filter_calcium_signal.m)

## Algorithm_Overview:
Explanation:
Using the Signal Itself for Filtering: The first image demonstrates the process where the signal itself is used as the reference for filtering. This method is useful when you assume that the pattern is consistent within the same signal, and you aim to emphasize regions that strongly correlate with the overall detected pattern.

Using a Reference Signal for Filtering: The second image illustrates the process when a separate reference signal is used to filter other signals. This approach is ideal when you have a trusted reference signal (such as the best-detected cell) and want to filter other signals to highlight regions that match this reference pattern.

These images provide an algorithm overview, visually explaining how the filtering process works—whether by using the signal itself or a reference signal—and how correlation and peak detection are applied to isolate relevant parts of the signal.

![Picture1](https://github.com/user-attachments/assets/b93e2a03-3a0e-41e8-a91e-c6cad44fafc6)


![Picture4](https://github.com/user-attachments/assets/49eef8d2-332a-415b-b354-488e150076f1)

### ECG and Calcium Imaging Analogy
- **ECG**: The peaks and troughs in the ECG signal represent electrical events like depolarization and repolarization in the heart's cells. These events are crucial for the mechanical contraction of the heart.
- **Calcium Imaging**: Similarly, in calcium imaging, the signal rises and falls with neuronal activity. When a neuron fires (action potential), calcium influx occurs, causing a peak in the signal. This is analogous to the peaks seen in the ECG corresponding to the heart’s electrical activity.

By leveraging the Pan-Tompkins algorithm, this tool can reliably identify these transient events (peaks) in calcium signals, enabling accurate extraction and filtering of significant signal segments. The robust nature of this algorithm makes it well-suited for handling the noisy and varied nature of biological data, such as calcium imaging.

### Steps:
1. **Peak Detection in Reference Signal**:
   - The function first detects peaks in the `ref_signal` (Reference signal, typically from the best-detected cell) using the Pan-Tompkins algorithm. This algorithm is well-suited for calcium imaging data due to the similar transient spike patterns observed, analogous to QRS complexes in ECG signals.

[View the code](https://github.com/AmirAli-Kalbasi/Calcium-Imaging-Signal-Filtering/blob/main/pan_tompkin.m)

[View souce](https://www.researchgate.net/publication/313673153_Matlab_Implementation_of_Pan_Tompkins_ECG_QRS_detector)

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
   - Other parts of the signal that do not meet these criteria are attenuated, resulting in the `filtered_signals` output.

### Parameters:
- `signal_data`: Matrix of calcium signals, where each row represents a cell.
- `ref_signal`: Reference signal, typically from the best detected cell.
- `consider_peak`: Boolean flag (default = 1) to include peak detection in filtering.
- `corr_window_size`: Window size for correlation calculation (default = 40).
- `peak_window_size`: Window size around detected peaks for filtering (default = 10).
- `corr_threshold`: Threshold for correlation values to be considered significant (default = 0.8).
- `fs`: Sampling frequency of the calcium imaging data (default = 1000).
- `pattern_len`: Length of the pattern used for correlation (default = 50).

#### Handling Very Noisy Cells
Very Noisy Cells: In the input (consider_peak), you can define a list (very_noisy_cells) where each element is set to 1 if the signal is not too noisy (i.e., it should be processed normally), or 0 if the signal is too noisy. For cells marked as too noisy, the function will rely more on correlation rather than thresholding during filtering, allowing for more aggressive noise suppression.

### Output:
- `filtered_signals`: A matrix of filtered signals, corresponding to the input `signal_data`, with non-relevant portions attenuated.

## Use_Case
This tool is particularly useful for researchers analyzing calcium imaging data who wish to focus on signal segments that are most relevant to a reference pattern. By filtering signals from other cells based on their correlation with the best detected cell, this approach helps in reducing noise and highlighting important cellular events.

## Example
```matlab
% Example data
data.temporal = ...; % Matrix of calcium signals where each row represents a cell

% Define the list of very noisy cells (e.g., indices of noisy cells)
result_list_very_noisy_cells = ....;

% Define the length of the list (assuming 40 as the maximum index)
list_length = size(data.temporal, 1);

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
