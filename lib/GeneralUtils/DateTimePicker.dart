
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateTimePicker {


  Future<Map<String, dynamic>> selectDate(String format, DateTime firstDate, DateTime initialDate, BuildContext context) async {


    var date = await showDatePicker(
      context: context,
      firstDate: firstDate,
      initialDate: initialDate,
      lastDate: DateTime(2100));

    // if(initialDate==null){
    //   initialDate= initialDate;
    // }

    if (date != null) {
      String dateStr = DateFormat(format).format(date);
      return {'selectedDate': dateStr, 'date': date};
    }
  }

  Future<Map<String, dynamic>> selectTime(BuildContext context, TimeOfDay initialTime) async {

    var time = await showTimePicker(context: context, initialTime: initialTime);

    if (time != null) {
      var hours = time.hour.toString();
      var minute = time.minute.toString();
      return {'selectedTime': '$hours:$minute', 'time': time};
    }
  }

  static bool isAdult2(String birthDateString) {
    String datePattern = "yyyy/MM/dd";

    // Current time - at this moment
    DateTime today = DateTime.now();

    // Parsed date to check
    DateTime birthDate = DateFormat(datePattern).parse(birthDateString);

    // Date to check but moved 18 years ahead
    DateTime adultDate = DateTime(
      birthDate.year + 18,
      birthDate.month,
      birthDate.day,
    );

    return adultDate.isBefore(today);
  }
}

