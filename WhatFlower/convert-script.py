# This Python Script file converts the CaffeModel to CoreMLModel
# Requirements: Python3, CoreMLTools
# Execute this file from terminal as: python3 convert-script.py

import coremltools

caffe_model = ('Flower Classifier/oxford102.caffemodel', 'Flower Classifier/deploy.prototxt')
labels = 'Flower Classifier/flower-labels.txt'
coreml_model = coremltools.converters.caffe.convert(caffe_model, class_labels = labels, image_input_names = 'data')
coreml_model.save('FlowerClassifier.mlmodel')
