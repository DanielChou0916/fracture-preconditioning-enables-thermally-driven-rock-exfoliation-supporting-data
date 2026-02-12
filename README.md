# Data and inputs for the thermal exfoliation paper

This repository contains the inputs and derived datasets that support the results and conclusions in the manuscript:

**"[Paper title here]"** (to be updated upon publication).

It includes:
- MOOSE/Felino input files used to run the simulations reported in the paper
- Derived data (CSV) underlying the figures and quantitative comparisons
- Jupyter notebooks used to post-process results and generate the manuscript figures

> Note: Full simulation output files (e.g., large Exodus `.e` files) are not included due to size. The archived CSV datasets are sufficient to reproduce all plots and quantitative conclusions in the manuscript. The provided inputs and scripts document the workflow.

---

## Software

Simulations were performed using:
- **Felino**: https://danielchou0916.github.io/felino.github.io/  
- **MOOSE Framework**: https://mooseframework.inl.gov/

Please cite the archived DOI of this repository (see “Citation” below) when referencing these materials.

**Version information**
- Felino version / commit: `[fill in commit hash or release tag]`
- MOOSE version / commit: `[fill in commit hash or release tag]`
- Operating system / environment notes (optional): `[e.g., Ubuntu 22.04, conda env, etc.]`

---

## Repository structure

- `inputs/`  
  MOOSE/Felino input files (`.i`) used to generate the simulations in the paper.  
  Each case folder corresponds to a figure or table in the manuscript.

- `CSV/`  
  Derived datasets in CSV format (e.g., extracted field values, curves, and summary quantities) used for plotting and analysis.

- `Python_notebooks/`  
  Jupyter notebooks (`.ipynb`) that read the CSV data and produce the figures in the manuscript.

---

## Figure-to-data mapping

The table below indicates which files reproduce each figure/table in the manuscript.

| Manuscript item | Input file(s) | CSV file(s) | Notebook |
|---|---|---|---|
| Fig. X | `inputs/...` | `CSV/...` | `Python_notebooks/...` |
| Fig. Y | `inputs/...` | `CSV/...` | `Python_notebooks/...` |

(Please update this mapping with the final figure numbers and filenames.)

---

## How to reproduce the figures (quick start)

1. Create a Python environment with Jupyter and common scientific packages (e.g., numpy, pandas, matplotlib).
2. Open the notebooks in `Python_notebooks/` and run all cells.
3. The notebooks will load the CSV files in `CSV/` and regenerate the manuscript figures.

If you wish to re-run the simulations from scratch, use the `.i` files in `inputs/` with Felino/MOOSE.

---

## License

- Data and derived CSV files: `[choose e.g., CC-BY-4.0 or CC0-1.0]`
- Notebooks and scripts: `[choose e.g., MIT]`

(Use a license compatible with your intent and any employer/IP constraints.)

---

## Citation

If you use this repository, please cite it as:

> Chou, D. (YEAR). Data and inputs for: *[Paper title]* (Version X.Y) [Data set]. **Zenodo**. DOI: `10.5281/zenodo.XXXXXXX`

(The DOI and citation will be updated after archival publication.)
