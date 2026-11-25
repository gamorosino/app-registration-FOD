<h1 align="center">FOD (CSD) Registration</h1>

<p align="center">
  Registers a subject's FA map to a fixed FA image (for example a template) with ANTs (translation, rigid, affine or SyN) and applies the transform to the CSD fibre orientation distributions with MRtrix3 FOD-aware reorientation.
</p>

<p align="center">
  <a href="https://github.com/brainlife/abcd-spec"><img src="https://img.shields.io/badge/ABCD_Spec-v1.1-green.svg" alt="ABCD Spec v1.1"></a>
  <a href="https://doi.org/10.25663/brainlife.app.849"><img src="https://img.shields.io/badge/Brainlife-brainlife.app.849-blue.svg" alt="Run on brainlife.io"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-see_LICENSE-lightgrey.svg" alt="License"></a>
</p>

## At a glance

<!-- brainlife-app:begin (generated from the App manifest; edit the manifest, not this block) -->

> **Registers a subject's FA map to a fixed FA image (for example a template) with ANTs (translation, rigid, affine or SyN) and applies the transform to the CSD fibre orientation distributions with MRtrix3 FOD-aware reorientation.**

Runs antsRegistration between the moving and fixed FA maps with a configurable transformation type and pyramid depth, then warps the FOD image of the selected lmax with the MRtrix3 chain warpinit, antsApplyTransforms, warpcorrect and mrtransform so the FODs are reoriented correctly. Use it to bring CSD FODs of a subject into another subject's or a template space, for example for population FOD analyses or template-space tractography. Only the FOD of the chosen lmax is transformed.

| | |
|---|---|
| **Inputs** | `neuro/csd` · `neuro/tensor` ×2 |
| **Outputs** | `neuro/csd` · `neuro/transform/nifti` |
| **Container** | `brainlife/ants:2.2.0-1bc` |
| **Resources** | 1 CPUs · 2 h walltime |
| **Run it** | [doi.org/10.25663/brainlife.app.849](https://doi.org/10.25663/brainlife.app.849) |

#### Inputs

| Input | Datatype | Required | Description |
|---|---|---|---|
| `moving-csd` | `neuro/csd` | yes | Moving FODs data. Must contain the FOD for the selected lmax. |
| `moving-tensor` | `neuro/tensor` | yes | Moving DTI Scalars Maps |
| `fixed-tensor` | `neuro/tensor` | yes | Fixed DTI Scalars Maps |

#### Outputs

| Output | Datatype | Description |
|---|---|---|
| `transformed` | `neuro/csd` | FOD image of the selected lmax resampled and reoriented into the fixed FA space. |
| `transformations` | `neuro/transform/nifti` | ANTs affine (affine.txt) and, for nonlinear registration, warp.nii.gz and inverse-warp.nii.gz. |

<details>
<summary><b>Parameters</b> (3)</summary>

| Parameter | Type | Default | Description |
|---|---|---|---|
| `lmax` | number | `4` | Select the appropriate value of lmax to be used. |
| `settings` | number | `4` | The `settings` parameter controls the depth of the multiresolution (pyramidal) registration strategy used by ANTs. Higher settings correspond to more levels in the registration pyramid, starting from coarse alignment and progressively refining toward finer spatial correspondence. |
| `transformation` | enum | `rigid` | Choose the type of registration from the following: 1) translation 2) rigid 3) affine 4) nonlinear (diffeomorphic SyN) Options: `translation`, `rigid`, `affine`, `nonlinear`. |

</details>

<!-- brainlife-app:end -->

## Running the App

### On brainlife.io

Open the App at [doi.org/10.25663/brainlife.app.849](https://doi.org/10.25663/brainlife.app.849), choose `neuro/csd`, `neuro/tensor`, `neuro/tensor` from your project, set the parameters and press **Execute**. The results are saved to your project as `neuro/csd`, `neuro/transform/nifti`.

### Locally

You need [Singularity/Apptainer](https://apptainer.org/) (the App runs in `brainlife/ants:2.2.0-1bc`), [`jq`](https://jqlang.github.io/jq/).

1. Clone this repository.
2. Create `config.json` with the paths to your inputs and the parameters:

   ```json
   {
       "response": "/path/to/moving-csd/response",
       "lmax2": "/path/to/moving-csd/lmax2",
       "lmax4": "/path/to/moving-csd/lmax4",
       "lmax6": "/path/to/moving-csd/lmax6",
       "lmax8": "/path/to/moving-csd/lmax8",
       "lmax10": "/path/to/moving-csd/lmax10",
       "lmax12": "/path/to/moving-csd/lmax12",
       "lmax14": "/path/to/moving-csd/lmax14",
       "fa": "/path/to/moving-tensor/fa",
       "md": "/path/to/moving-tensor/md",
       "rd": "/path/to/moving-tensor/rd",
       "ad": "/path/to/moving-tensor/ad",
       "cl": "/path/to/moving-tensor/cl",
       "cp": "/path/to/moving-tensor/cp",
       "cs": "/path/to/moving-tensor/cs",
       "tensors": "/path/to/moving-tensor/tensors",
       "kurtosis": "/path/to/moving-tensor/kurtosis",
       "ga": "/path/to/moving-tensor/ga",
       "mk": "/path/to/moving-tensor/mk",
       "ak": "/path/to/moving-tensor/ak",
       "rk": "/path/to/moving-tensor/rk",
       "rgb": "/path/to/moving-tensor/rgb",
       "fa_fixed": "/path/to/fixed-tensor/fa_fixed",
       "md_fixed": "/path/to/fixed-tensor/md_fixed",
       "rd_fixed": "/path/to/fixed-tensor/rd_fixed",
       "ad_fixed": "/path/to/fixed-tensor/ad_fixed",
       "cl_fixed": "/path/to/fixed-tensor/cl_fixed",
       "cp_fixed": "/path/to/fixed-tensor/cp_fixed",
       "cs_fixed": "/path/to/fixed-tensor/cs_fixed",
       "tensors_fixed": "/path/to/fixed-tensor/tensors_fixed",
       "kurtosis_fixed": "/path/to/fixed-tensor/kurtosis_fixed",
       "ga_fixed": "/path/to/fixed-tensor/ga_fixed",
       "mk_fixed": "/path/to/fixed-tensor/mk_fixed",
       "ak_fixed": "/path/to/fixed-tensor/ak_fixed",
       "rk_fixed": "/path/to/fixed-tensor/rk_fixed",
       "rgb_fixed": "/path/to/fixed-tensor/rgb_fixed",
       "lmax": 4,
       "settings": 4,
       "transformation": "rigid"
   }
   ```

3. Run `./main`.

## Features

This pipeline performs:
- Nonlinear registration of FA images using ANTs
- Application of the resulting transformations to FOD data using `warpinit → antsApplyTransforms → warpcorrect → mrtransform`
- All transformations and tools are executed via Singularity containers
- Clean, modular design with FOD transformation handled in a dedicated helper script

## Example `config.json`:

```json
{
    "lmax": 8,
    "fa": "input/fa.nii.gz",
    "fa_fixed": "template/fa_template.nii.gz",
    "lmax8": "input/lmax8.mif",
    "settings": "3"
}
```

## Field Descriptions

| Field       | Description                                                  |
|-------------|--------------------------------------------------------------|
| `lmax`      | Spherical harmonic order of FOD (e.g., `8`)                             |
| `lmax<lmax>`     | FOD image for the selected `lmax` (e.g., `lmax8`)            |
| `fa`        | FA image to register (moving image)                          |
| `fa_fixed`  | Reference FA image (fixed image)                              |
| `settings`  | Registration complexity level (1–4, see table below)         |

---

## Registration Settings

The `settings` parameter controls the depth of the multiresolution (pyramidal) registration strategy used by ANTs. Higher settings correspond to more levels in the registration pyramid, starting from coarse alignment and progressively refining toward finer spatial correspondence.

| Value | Description                    | Pyramid Levels                                  |  Iterations (Linear)              | Iterations (SyN)                | Shrink Factors (Resolution Downsampling) |
|-------|--------------------------------|--------------------------------------------------|---------------------------|-------------------------------|-------------------------------------------|
| 1     | Coarse, single-level registration | 1-level (coarse only)                          | `10000x0x0`              | `100x0x0`                 | `4x2x1`                                   |
| 2     | Coarse-to-medium registration     | 2-level pyramid                                | `10000x10000x0`          | `100x100x0`           | `4x2x1`                                   |
| 3     | Coarse-to-fine registration       | 3-level pyramid                                | `10000x111110x11110`     | `100x100x30`          | `4x2x1`                                   |
| 4     | Full multiresolution registration | 4-level pyramid (coarse → fine)                | `10000x10000x10000`      | `100x80x50x20`       | `8x4x2x1`                                 |

## Notes:

- **Iterations** specify the number of optimization steps per level.
- **Syn Parameters** define the parameters for the Symmetric Normalization (SyN) transformation model.
- **Shrink Factors** determine the level of image resolution downsampling at each pyramid level (from coarse to fine). For example, `8x4x2x1` means:
  - Level 1: image downsampled by 8
  - Level 2: downsampled by 4
  - Level 3: downsampled by 2
  - Level 4: full resolution

---

## 1. Clone the repository

```bash
git clone https://github.com/gamorosino/app-registration-FOD.git
cd app-registration-FOD
```

## 2. Prepare your configuration

Edit the `config.json` file to point to your FA, template FA, FOD, and desired settings level.

## 3. Run the pipeline

```bash
./main
```

This will:
- Run ANTs registration
- Apply the estimated warp and affine to the FOD image using MRtrix3
- Save the transformed FOD image to the `transformed/` folder

---

## Usage on Brainlife.io

This app is structured for deployment on [Brainlife.io](https://brainlife.io/).

## Web UI

1. Locate the `app-registration-FOD` app on Brainlife.
2. Execute the pipeline via the graphical interface.

## CLI

```bash
bl login
bl app run --id <app_id> \
           --project <project_id> \
           --input fa:<fa_object> fa_fixed:<template_object> fod:<fod_object> ...
```

---

## Citing

If you use this App, please cite it, the software it builds on and brainlife.io:

- FOD (CSD) Registration. brainlife.io App. [doi:10.25663/brainlife.app.849](https://doi.org/10.25663/brainlife.app.849)
- **ANTs**: Avants et al., *NeuroImage* (2011) https://doi.org/10.1016/j.neuroimage.2010.09.025
- **MRtrix3**: Tournier et al., *NeuroImage* (2019) https://doi.org/10.1016/j.neuroimage.2019.116137
- Hayashi S, Caron BA, Heinsfeld AS, et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. *Nature Methods* 21:809–813 (2024). [doi:10.1038/s41592-024-02237-2](https://doi.org/10.1038/s41592-024-02237-2)
- Avesani P, McPherson B, Hayashi S, et al. The open diffusion data derivatives, brain data upcycling via integrated publishing of derivatives and reproducible open cloud services. *Scientific Data* 6:69 (2019). [doi:10.1038/s41597-019-0073-y](https://doi.org/10.1038/s41597-019-0073-y)

## Authors

Gabriele Amorosino

---

## License

See [LICENSE](LICENSE).
