import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sports_studio/core/network/api_services.dart';
import 'package:sports_studio/core/models/models.dart';
import 'package:sports_studio/core/utils/app_utils.dart';
import 'package:sports_studio/features/user/controller/profile_controller.dart';
import 'package:sports_studio/features/user/presentation/pages/event_detail_page.dart';

class EventsController extends GetxController {
  final RxBool isLoadingEvents = false.obs;
  final RxBool isLoadingEvent = false.obs;
  final RxBool isCreatingEvent = false.obs;
  final RxBool isJoiningEvent = false.obs;
  final RxList<Event> events = <Event>[].obs;
  final RxList<Event> userEvents = <Event>[].obs;
  final Rxn<Event> selectedEvent = Rxn<Event>();
  final RxString selectedEventType = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Event creation form controllers
  final eventNameController = TextEditingController();
  final eventDescriptionController = TextEditingController();
  final eventRulesController = TextEditingController();
  final eventSafetyPolicyController = TextEditingController();
  final eventLocationController = TextEditingController();
  final eventMaxParticipantsController = TextEditingController(text: '10');
  final eventRegistrationFeeController = TextEditingController(text: '0');
  final Rx<DateTime> eventStartDate = DateTime.now().obs;
  final Rx<DateTime> eventEndDate = DateTime.now()
      .add(const Duration(hours: 2))
      .obs;
  final RxString eventSportType = 'cricket'.obs;
  final RxString eventVisibility = 'public'.obs;
  final RxList<String> eventImages = <String>[].obs;
  final RxDouble eventLatitude = 0.0.obs;
  final RxDouble eventLongitude = 0.0.obs;

  final EventApiService _eventApiService = EventApiService();
  final EventParticipantApiService _participantApiService =
      EventParticipantApiService();

  @override
  void onInit() {
    super.onInit();
    fetchPublicEvents();
  }

  Future<void> fetchPublicEvents() async {
    isLoadingEvents.value = true;
    try {
      final eventList = await _eventApiService.getPublicEvents();
      events.value = eventList;
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch events: $e');
    } finally {
      isLoadingEvents.value = false;
    }
  }

  Future<void> fetchUserEvents() async {
    isLoadingEvents.value = true;
    try {
      final profileController = Get.find<ProfileController>();
      final userId = profileController.userProfile['id'];
      final eventList = await _eventApiService.getUserEvents(organizerId: userId);
      userEvents.value = eventList;
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch user events: $e');
    } finally {
      isLoadingEvents.value = false;
    }
  }

  Future<void> fetchEventDetail(String idOrSlug) async {
    isLoadingEvent.value = true;
    try {
      final event = await _eventApiService.getPublicEvent(idOrSlug);
      selectedEvent.value = event;
    } catch (e) {
      AppUtils.showError(message: 'Failed to fetch event detail: $e');
    } finally {
      isLoadingEvent.value = false;
    }
  }

  // Alias method for compatibility with event detail page
  Future<void> getEventById(String id) async {
    await fetchEventDetail(id);
  }

  Future<void> createEvent(int groundId) async {
    if (eventNameController.text.trim().isEmpty) {
      AppUtils.showError(message: 'Event name is required');
      return;
    }

    if (eventStartDate.value.isAfter(eventEndDate.value)) {
      AppUtils.showError(message: 'End time must be after start time');
      return;
    }

    isCreatingEvent.value = true;
    try {
      final eventData = {
        'name': eventNameController.text.trim(),
        'description': eventDescriptionController.text.trim(),
        'start_time': DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(eventStartDate.value),
        'end_time': DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(eventEndDate.value),
        'registration_fee':
            double.tryParse(eventRegistrationFeeController.text) ?? 0.0,
        'max_participants':
            int.tryParse(eventMaxParticipantsController.text) ?? 10,
        'ground_id': groundId,
        'latitude': eventLatitude.value != 0.0 ? eventLatitude.value : null,
        'longitude': eventLongitude.value != 0.0 ? eventLongitude.value : null,
        'rules': eventRulesController.text.trim(),
        'safety_policy': eventSafetyPolicyController.text.trim(),
        'images': eventImages,
        'location': eventLocationController.text.trim(),
        'event_type': eventVisibility.value,
        'status': 'upcoming',
      };

      final event = await _eventApiService.createEvent(eventData);
      clearEventForm();
      Get.back();
      AppUtils.showSuccess(message: 'Event created successfully!');
      Get.to(() => const EventDetailPage(), arguments: event);
    } catch (e) {
      AppUtils.showError(message: 'Failed to create event: $e');
    } finally {
      isCreatingEvent.value = false;
    }
  }

  Future<void> updateEvent(int id, String slug) async {
    if (eventNameController.text.trim().isEmpty) {
      AppUtils.showError(message: 'Event name is required');
      return;
    }

    isCreatingEvent.value = true;
    try {
      final eventData = {
        'name': eventNameController.text.trim(),
        'description': eventDescriptionController.text.trim(),
        'start_time': DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(eventStartDate.value),
        'end_time': DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(eventEndDate.value),
        'registration_fee':
            double.tryParse(eventRegistrationFeeController.text) ?? 0.0,
        'max_participants':
            int.tryParse(eventMaxParticipantsController.text) ?? 10,
        'latitude': eventLatitude.value != 0.0 ? eventLatitude.value : null,
        'longitude': eventLongitude.value != 0.0 ? eventLongitude.value : null,
        'rules': eventRulesController.text.trim(),
        'safety_policy': eventSafetyPolicyController.text.trim(),
        'images': eventImages,
        'location': eventLocationController.text.trim(),
        'event_type': eventVisibility.value,
      };

      final event = await _eventApiService.updateEvent(slug, eventData);
      selectedEvent.value = event;
      Get.back();
      AppUtils.showSuccess(message: 'Event updated successfully!');
    } catch (e) {
      AppUtils.showError(message: 'Failed to update event: $e');
    } finally {
      isCreatingEvent.value = false;
    }
  }

  Future<void> deleteEvent(int id, String slug) async {
    try {
      await _eventApiService.deleteEvent(slug);
      userEvents.removeWhere((event) => event.id == id);
      events.removeWhere((event) => event.id == id);
      Get.back();
      AppUtils.showSuccess(message: 'Event deleted successfully');
    } catch (e) {
      AppUtils.showError(message: 'Failed to delete event: $e');
    }
  }

  Future<void> joinEvent(int eventId, {double? registrationFee}) async {
    isJoiningEvent.value = true;
    try {
      final participantData = {
        'event_id': eventId,
        'status': 'confirmed',
        'payment_status': registrationFee != null && registrationFee > 0
            ? 'unpaid'
            : 'paid',
      };

      await _participantApiService.joinEvent(participantData);
      AppUtils.showSuccess(message: 'Successfully joined the event!');

      // Update the event in the lists
      _updateEventInLists(eventId, isJoining: true);
      
      // Refresh to get latest stats from backend if needed
      fetchPublicEvents();
      fetchUserEvents();
    } catch (e) {
      AppUtils.showError(message: 'Failed to join event: $e');
    } finally {
      isJoiningEvent.value = false;
    }
  }

  Future<void> leaveEvent(int participantId) async {
    try {
      await _participantApiService.leaveEvent(participantId);
      AppUtils.showSuccess(message: 'Successfully left the event');

      // Update the event in the lists
      if (selectedEvent.value != null) {
        _updateEventInLists(selectedEvent.value!.id, isJoining: false);
      }
      
      // Refresh to get latest stats
      fetchPublicEvents();
      fetchUserEvents();
    } catch (e) {
      AppUtils.showError(message: 'Failed to leave event: $e');
    }
  }

  void _updateEventInLists(int eventId, {required bool isJoining}) {
    // Helper to update a single event object
    Event updateEvent(Event event) {
      return Event(
        id: event.id,
        name: event.name,
        description: event.description,
        startTime: event.startTime,
        endTime: event.endTime,
        registrationFee: event.registrationFee,
        maxParticipants: event.maxParticipants,
        organizerId: event.organizerId,
        rules: event.rules,
        safetyPolicy: event.safetyPolicy,
        schedule: event.schedule,
        location: event.location,
        image: event.image,
        slug: event.slug,
        bookingId: event.bookingId,
        status: event.status,
        participantsCount: (event.participantsCount ?? 0) + (isJoining ? 1 : -1),
        userJoined: isJoining,
        organizer: event.organizer,
        booking: event.booking,
      );
    }

    // Update selectedEvent
    if (selectedEvent.value != null && selectedEvent.value!.id == eventId) {
      selectedEvent.value = updateEvent(selectedEvent.value!);
    }

    // Update events list
    int index = events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      events[index] = updateEvent(events[index]);
      events.refresh();
    }

    // Update userEvents list
    int userIndex = userEvents.indexWhere((e) => e.id == eventId);
    if (userIndex != -1) {
      userEvents[userIndex] = updateEvent(userEvents[userIndex]);
      userEvents.refresh();
    }
  }

  // Check if user has joined the selected event
  bool get hasJoinedSelectedEvent {
    return selectedEvent.value?.userJoined ?? false;
  }

  // Check if selected event is full
  bool get isSelectedEventFull {
    final event = selectedEvent.value;
    if (event == null || event.maxParticipants == 0) return false;
    return (event.participantsCount ?? 0) >= (event.maxParticipants ?? 0);
  }

  void filterEvents() {
    var filtered = events.where((event) {
      bool matchesSearch =
          event.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          (event.description?.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ??
              false);

      bool matchesType =
          selectedEventType.value == 'all' ||
          event.status == selectedEventType.value;

      return matchesSearch && matchesType;
    }).toList();

    // Update filtered list (you might want to create a separate filtered list variable)
    events.assignAll(filtered);
  }

  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterEvents();
  }

  void updateSelectedEventType(String type) {
    selectedEventType.value = type;
    filterEvents();
  }

  void clearEventForm() {
    eventNameController.clear();
    eventDescriptionController.clear();
    eventRulesController.clear();
    eventSafetyPolicyController.clear();
    eventLocationController.clear();
    eventMaxParticipantsController.text = '10';
    eventRegistrationFeeController.text = '0';
    eventStartDate.value = DateTime.now();
    eventEndDate.value = DateTime.now().add(const Duration(hours: 2));
    eventSportType.value = 'cricket';
    eventVisibility.value = 'public';
    eventImages.clear();
    eventLatitude.value = 0.0;
    eventLongitude.value = 0.0;
  }

  void populateEventForm(Event event) {
    eventNameController.text = event.name;
    eventDescriptionController.text = event.description ?? '';
    eventRulesController.text = event.rules ?? '';
    eventSafetyPolicyController.text = event.safetyPolicy ?? '';
    eventLocationController.text = event.location ?? '';
    eventMaxParticipantsController.text = event.maxParticipants.toString();
    eventRegistrationFeeController.text = event.registrationFee.toString();
    eventStartDate.value = event.startTime;
    eventEndDate.value = event.endTime;
    eventVisibility.value = event.eventType;
    eventImages.value = event.images.isNotEmpty ? List<String>.from(event.images) : (event.image != null ? [event.image!] : []);
    eventLatitude.value = event.latitude ?? 0.0;
    eventLongitude.value = event.longitude ?? 0.0;
  }

  void addEventImage(String imagePath) {
    if (eventImages.length < 5) {
      // Limit to 5 images
      eventImages.add(imagePath);
    } else {
      AppUtils.showError(message: 'Maximum 5 images allowed');
    }
  }

  void removeEventImage(String imagePath) {
    eventImages.remove(imagePath);
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedEventType.value = 'all';
    fetchPublicEvents();
  }

  @override
  void onClose() {
    eventNameController.dispose();
    eventDescriptionController.dispose();
    eventRulesController.dispose();
    eventSafetyPolicyController.dispose();
    eventLocationController.dispose();
    eventMaxParticipantsController.dispose();
    eventRegistrationFeeController.dispose();
    super.onClose();
  }
}
