import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hang_out_app/data/models/event.dart';
import 'package:hang_out_app/presentation/utils/colors.dart';
import 'package:hang_out_app/presentation/utils/constants.dart';
import 'package:hang_out_app/presentation/utils/fonts.dart';
import 'package:hang_out_app/presentation/utils/icons.dart';
import 'package:hang_out_app/presentation/utils/screen_size_utils.dart';
import 'package:hang_out_app/presentation/utils/tablet_constants.dart';
import 'package:hang_out_app/presentation/widgets/custom_text.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatefulWidget {
  final List<Event>? _events;

  const CalendarWidget({super.key, List<Event>? events}) : _events = events;

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  // late final ValueNotifier<List<Event>> _selectedEvents;
  final StartingDayOfWeek _startingDayOfWeek = StartingDayOfWeek.monday;
  final RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .disabled; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  final DateTime _selectedDay = DateTime.now();

  // final List<DateTime> _eventDays = events;

  @override
  Widget build(BuildContext context) {
    if (getSize(context) == ScreenSize.normal) {
      return _buildPhoneCalendar();
    }
    return _buildTabletCalendar();
  }

  Widget _buildPhoneCalendar() {
    CalendarFormat calendarFormat = CalendarFormat.twoWeeks;

    return TableCalendar(
      rowHeight: 30.0.h,
      headerStyle: HeaderStyle(
          leftChevronIcon: Icon(
            AppIcons.arrowIosBackOutline,
            size: Constants.iconDimension,
            color: Theme.of(context).primaryColor,
          ),
          rightChevronIcon: Icon(
            AppIcons.arrowIosForwardOutline,
            size: Constants.iconDimension,
            color: Theme.of(context).primaryColor,
          ),
          leftChevronPadding:
              EdgeInsets.symmetric(vertical: 12.0.h, horizontal: 0.0.w),
          rightChevronPadding:
              EdgeInsets.symmetric(vertical: 12.0.h, horizontal: 0.0.w),
          formatButtonVisible: false,
          titleCentered: true,
          headerPadding: EdgeInsets.zero,
          titleTextStyle: TextStyle(fontFamily: "Inter", fontSize: 16.r)),
      daysOfWeekStyle: DaysOfWeekStyle(
        dowTextFormatter: (date, locale) =>
            DateFormat.E(locale).format(date).toUpperCase(),
        weekdayStyle: const TextStyle(
            // color: AppColors.blackColor,
            fontFamily: "Inter",
            fontWeight: Fonts.regular),
      ),
      weekendDays: const [],
      calendarStyle: const CalendarStyle(
        // selectedTextStyle: TextStyle(color: Colors.amber),
        cellAlignment: Alignment.bottomCenter,
        isTodayHighlighted: false,
        cellMargin: EdgeInsets.all(0),
        // defaultDecoration: BoxDecoration(color: Colors.white),
      ),
      startingDayOfWeek: _startingDayOfWeek,
      rangeSelectionMode: _rangeSelectionMode,
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2050, 01, 01),
      focusedDay: _focusedDay,
      calendarFormat: calendarFormat,
      // onFormatChanged: (format) {
      //   setState(() {
      //     _calendarFormat = format;
      //   });
      // },
      selectedDayPredicate: (day) {
        return isEventDay(day) || isSameDay(day, _selectedDay);
      },
      //This makes days before today unclickable, can be removed to make all clickable
      // enabledDayPredicate: (day) {
      //   return day.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      // },
      //This is used to click and select a day
      // onDaySelected: (selectedDay, focusedDay) {
      //   setState(() {
      //     _selectedDay = selectedDay;
      //     _focusedDay = focusedDay; // update `_focusedDay` here as well
      //   });
      // },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarBuilders: CalendarBuilders(selectedBuilder: (context, date, _) {
        Color eventColor = getDayColor(date);
        bool isToday = isSameDay(date, DateTime.now());
        return Stack(
          children: [
            isToday
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.transparent,
                      ),
                      width: 15.r,
                      height: 15.r,
                    ),
                  )
                : const SizedBox(),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: eventColor,
                ),
                width: 10.r,
                height: 10.r,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomText(
                text: '${date.day}',
                fontWeight: isToday ? Fonts.black : Fonts.regular,
                size: isToday
                    ? Constants.calendarTodayNumberDimension
                    : Constants.calendarDefaultNumberDimension,
                textDecoration: isToday ? TextDecoration.underline : null,
                // color: isToday ? AppColors.whiteColor : null,
              ),
            ),
          ],
        );
      }, defaultBuilder: (context, date, _) {
        return CustomText(
          text: '${date.day}',
          fontWeight: Fonts.regular,
          size: Constants.calendarDefaultNumberDimension,
          // color: isToday ? AppColors.whiteColor : null,
        );
      }),
    );
  }

  Widget _buildTabletCalendar() {
    CalendarFormat calendarFormat = CalendarFormat.month;
    double rowHeight;
    MediaQuery.of(context).orientation == Orientation.portrait
        ? rowHeight = 43
        : rowHeight = 95;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        // color: AppColors.greenColor,
      ),
      child: TableCalendar(
        rowHeight: TabletConstants.resizeH(rowHeight),
        daysOfWeekHeight: TabletConstants.resizeH(16),
        headerStyle: HeaderStyle(
            leftChevronIcon: Icon(
              AppIcons.arrowIosBackOutline,
              size: TabletConstants.iconDimension(),
              color: Theme.of(context).primaryColor,
            ),
            rightChevronIcon: Icon(
              AppIcons.arrowIosForwardOutline,
              size: TabletConstants.iconDimension(),
              color: Theme.of(context).primaryColor,
            ),
            leftChevronPadding: EdgeInsets.symmetric(
                vertical: TabletConstants.resizeR(35),
                horizontal: TabletConstants.resizeR(35)),
            rightChevronPadding: EdgeInsets.symmetric(
                vertical: TabletConstants.resizeR(35),
                horizontal: TabletConstants.resizeR(35)),
            formatButtonVisible: false,
            titleCentered: true,
            headerPadding: EdgeInsets.zero,
            titleTextStyle: TextStyle(
                fontFamily: "Inter", fontSize: TabletConstants.resizeR(24))),
        daysOfWeekStyle: DaysOfWeekStyle(
          dowTextFormatter: (date, locale) =>
              DateFormat.E(locale).format(date).toUpperCase(),
          weekdayStyle: TextStyle(
            // color: AppColors.blackColor,
            fontFamily: "Inter",
            fontWeight: Fonts.semiBold,
            fontSize: TabletConstants.resizeR(16),
          ),
        ),
        weekendDays: const [],
        calendarStyle: const CalendarStyle(
          // selectedTextStyle: TextStyle(color: Colors.amber),
          cellAlignment: Alignment.bottomCenter,
          isTodayHighlighted: false,
          cellMargin: EdgeInsets.all(0),
          // defaultDecoration: BoxDecoration(color: Colors.white),
        ),
        startingDayOfWeek: _startingDayOfWeek,
        rangeSelectionMode: _rangeSelectionMode,
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2050, 01, 01),
        focusedDay: _focusedDay,
        calendarFormat: calendarFormat,
        // onFormatChanged: (format) {
        //   setState(() {
        //     _calendarFormat = format;
        //   });
        // },
        selectedDayPredicate: (day) {
          return isEventDay(day) || isSameDay(day, _selectedDay);
        },
        //This makes days before today unclickable, can be removed to make all clickable
        // enabledDayPredicate: (day) {
        //   return day.isAfter(DateTime.now().subtract(const Duration(days: 1)));
        // },
        //This is used to click and select a day
        // onDaySelected: (selectedDay, focusedDay) {
        //   setState(() {
        //     _selectedDay = selectedDay;
        //     _focusedDay = focusedDay; // update `_focusedDay` here as well
        //   });
        // },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarBuilders: CalendarBuilders(selectedBuilder: (context, date, _) {
          Color eventColor = getDayColor(date);
          bool isToday = isSameDay(date, DateTime.now());
          return Stack(
            children: [
              isToday
                  ? Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.transparent,
                        ),
                        width: TabletConstants.resizeR(15),
                        height: TabletConstants.resizeR(15),
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: EdgeInsets.only(right: TabletConstants.resizeR(15)),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: eventColor,
                    ),
                    width: TabletConstants.resizeR(20),
                    height: TabletConstants.resizeR(20),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: CustomText(
                  text: '${date.day}',
                  fontWeight: isToday ? Fonts.black : Fonts.regular,
                  size: isToday
                      ? TabletConstants.resizeR(20)
                      : TabletConstants.resizeR(18),
                  textDecoration: isToday ? TextDecoration.underline : null,
                  // color: isToday ? AppColors.whiteColor : null,
                ),
              ),
            ],
          );
        }, defaultBuilder: (context, date, _) {
          return CustomText(
            text: '${date.day}',
            fontWeight: Fonts.regular,
            size: TabletConstants.resizeR(18),
            // color: isToday ? AppColors.whiteColor : null,
          );
        }),
      ),
    );
  }

  Color getDayColor(DateTime day) {
    for (final event in widget._events ?? []) {
      if (isSameDay(day, event.date.toDate())) {
        return CategoryColors.getColor(event.category);
      }
    }
    return Colors.transparent;
  }

  bool isEventDay(DateTime day) {
    for (final event in widget._events ?? []) {
      if (isSameDay(day, event.date.toDate())) {
        return true;
      }
    }
    return false;
  }
}
