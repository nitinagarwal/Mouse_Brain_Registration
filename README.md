# Geometry Processing of Conventionally Produced Mouse Brain Slices. 

This is the code to register mouse brain microscopic images with annotated ARA atlas images. The method extracts dominant edges from both input images and aligns them using non-linear transformation. For more details please read the paper.

## Getting Started

To run the demo, download the sample data
```
bash download_dataset.sh
```

Compile mex files
```
mex solveLaplace.cpp
```

Please read the run_me.m file.

## Citation
If you use the code/data, please cite the following paper:

```
@article{agarwal2017mouse,
  author = {Nitin Agarwal, Xiangmin Xu, Gopi Meenakshisundaram},
  title = {Geometry Processing of Conventionally Produced Mouse Brain Slice Images},
  journal = {arXiv:1712.09684},
  year = {2017}
}
```

## License

Our code is released under MIT License (see License file for details).

## Contact

Please contact [Nitin Agarwal](http://www.ics.uci.edu/~agarwal/) if you have any questions or comments.
