import 'dart:convert';
import 'dart:developer';

import 'repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class LoginRepository extends Repository {
      
  Future<void> logout() async {
      try {
        // Initialize Dio and SharedPreferences
        final Dio dio = Dio();
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        // Get session token from SharedPreferences
        final String sessionToken = prefs.getString('session') ?? "";

        // Prepare data for the POST request
        final Map<String, dynamic> fdataMap = {'session_token': sessionToken};
        final FormData fdata = FormData.fromMap(fdataMap);

        // Make a POST request to logout
        final response = await dio.post(
          'https://me-dis.000webhostapp.com/logout-api.php',
          data: fdata,
        );

        // Log response for debugging
        print("Logout response: $response");

        // Remove the session token from SharedPreferences
        prefs.remove('session');

      } catch (error) {
        // Handle error if needed
        print('Error during logout: $error');
      }
    }

    Future<Map<String, dynamic>> login({
        required String username,
        required String password,
      }) async {
        final Dio dio = Dio();
        final FormData fdata = FormData.fromMap({'user': username, 'pwd': password});

        try {
          final Response response = await dio.post(
            'https://me-dis.000webhostapp.com/login-api.php',
            data: fdata,
          );

          // Log response for debugging
          print("Login response: $response");

          Map<String, dynamic> repoResponse = {'status': false, 'data': null};

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.data);

            if (data['status'] == 'success') {
              repoResponse['status'] = true;
              repoResponse['data'] = data;

              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('session', data['session_token']);
            } else {
              repoResponse['data'] = data;
            }
          }

          return repoResponse;
        } catch (error) {
          // Handle error if needed
          print('Error during login: $error');
          return {'status': false, 'data': null};
        }
      }
}