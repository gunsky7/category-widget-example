// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO: Import relevant packages

import 'dart:convert';
import 'dart:io';

const apiCategory = {
  "name" : "Currency",
  "route" : "currency",
};

/// The REST API retrieves unit conversions for [Categories] that change.
///
/// For example, the currency exchange rate, stock prices, the height of the
/// tides change often.
/// We have set up an API that retrieves a list of currencies and their current
/// exchange rate (mock data).
///   GET /currency: get a list of currencies
///   GET /currency/convert: get conversion from one currency amount to another
class Api {
  final HttpClient _httpClient = HttpClient();

  final String _url = "flutter.udacity.com";

  Future<List> getUnits(String category) async {
    final uri = Uri.https(_url, "/$category");
    final jsonResponse = await _getJson(uri);

    if (jsonResponse == null || jsonResponse["units"] == null) {
      print("Error retrieve units.");
      return null;
    }

    return jsonResponse["units"];
  }

  Future<double> convert(String category, String amount, String fromUnit, String toUnit) async {
    final uri = Uri.https(_url, "/$category/convert", {"amount" : amount, "from" : fromUnit, "to" : toUnit});
    final jsonResponse = await _getJson(uri);

    if (jsonResponse == null || jsonResponse["status"] == null) {
      print("Error retrieve conversion.");
      return null;
    } else if (jsonResponse["status"] == "error"){
      print(jsonResponse["message"]);
      return null;
    }

    return jsonResponse["conversion"].toDouble();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();

      if (httpResponse.statusCode != HttpStatus.ok) {
        return null;
      }

      final responseBody = await httpResponse.transform(utf8.decoder).join();

      return jsonDecode(responseBody);
    } on Exception catch (e) {
      print("$e");
      return null;
    }
  }
}