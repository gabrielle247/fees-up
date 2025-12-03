// lib/utils/student_codec.dart (DEFINITIVE FIX - Revised Converter Logic)

import 'dart:async';
import 'dart:convert'; // Provides Codec and Converter
import 'package:flutter/foundation.dart';
import '../features/students/data/student_model.dart';

// --- 1. Define the Core Logic Functions ---

// Encoder Function (Serialization: Student -> Map)
Object? studentEncoder(Object? input) {
  if (input is Student) {
    return input.toMap();
  }
  return input;
}

// Decoder Function (Deserialization: Map -> Student)
Object? studentDecoder(Object? input) {
  if (input is Map<String, dynamic> && input.containsKey('id')) {
    try {
      return Student.fromMap(input);
    } catch (e) {
      debugPrint('Error decoding Student from Map: $e');
      return input;
    }
  }
  return input;
}

// --- 2. Define a Concrete Converter ---

/// A simple, concrete implementation of a Converter that uses a function.
/// This avoids relying on potentially missing static factory methods (like fromFunction).
class StudentConverter extends Converter<Object?, Object?> {
  final Object? Function(Object?) _convert;

  StudentConverter(this._convert);

  @override
  Object? convert(Object? input) => _convert(input);

  // Since Converter is also a StreamTransformer, we must implement these.
  @override
  Stream<Object?> bind(Stream<Object?> stream) => stream.map(convert);
}


// --- 3. Define the Concrete Codec Subclass ---

/// This concrete class implements the abstract Codec.
class StudentGoRouterCodec extends Codec<Object?, Object?> {
  
  @override
  // Encoder uses the StudentConverter wrapper around the studentEncoder function
  Converter<Object?, Object?> get encoder => StudentConverter(studentEncoder);

  @override
  // Decoder uses the StudentConverter wrapper around the studentDecoder function
  Converter<Object?, Object?> get decoder => StudentConverter(studentDecoder);
}

// --- 4. Instantiate the final Codec variable ---

final Codec<Object?, Object?> studentCodec = StudentGoRouterCodec();