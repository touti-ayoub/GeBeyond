import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gobeyond/core/services/itinerary_service.dart';
import 'package:gobeyond/features/itinerary/domain/entities/itinerary.dart';
import 'package:gobeyond/features/itinerary/domain/entities/itinerary_item.dart';

class ItineraryDetailScreen extends StatefulWidget {
  final int itineraryId;

  const ItineraryDetailScreen({super.key, required this.itineraryId});

  @override
  State<ItineraryDetailScreen> createState() => _ItineraryDetailScreenState();
}

class _ItineraryDetailScreenState extends State<ItineraryDetailScreen> {
  final ItineraryService _itineraryService = ItineraryService();
  bool _isLoading = true;
  Itinerary? _itinerary;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _itineraryService.initialize();
    await _itineraryService.loadItineraries();
    _loadItinerary();
  }

  void _loadItinerary() {
    final itineraries = _itineraryService.itineraries;
    _itinerary = itineraries.firstWhere(
      (i) => i.id == widget.itineraryId,
      orElse: () => throw Exception('Itinerary not found'),
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _itinerary == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final dateFormat = DateFormat('MMM dd, yyyy');
    final items = _itineraryService.getItemsForItinerary(widget.itineraryId);

    return Scaffold(
      appBar: AppBar(
        title: Text(_itinerary!.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _itineraryService,
        builder: (context, _) {
          final updatedItems =
              _itineraryService.getItemsForItinerary(widget.itineraryId);

          return CustomScrollView(
            slivers: [
              // Header Card
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_itinerary!.destination != null) ...[
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Theme.of(context).primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _itinerary!.destination!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              '${dateFormat.format(_itinerary!.startDate)} - ${dateFormat.format(_itinerary!.endDate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.event,
                                size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              '${_itinerary!.numberOfDays} days',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 24),
                            Icon(Icons.list_alt,
                                size: 20, color: Colors.grey[600]),
                            const SizedBox(width: 8),
                            Text(
                              '${updatedItems.length} items',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        if (_itinerary!.notes != null &&
                            _itinerary!.notes!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(
                            _itinerary!.notes!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Items Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Timeline',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => _showAddItemDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Item'),
                      ),
                    ],
                  ),
                ),
              ),

              // Items List
              updatedItems.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_note,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No items yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add activities, bookings, or notes',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = updatedItems[index];
                          return _buildItemCard(item, index == updatedItems.length - 1);
                        },
                        childCount: updatedItems.length,
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemCard(ItineraryItem item, bool isLast) {
    final timeFormat = DateFormat('h:mm a');
    final dateFormat = DateFormat('MMM dd');

    IconData icon;
    Color iconColor;
    switch (item.itemType) {
      case ItemType.booking:
        icon = Icons.flight_takeoff;
        iconColor = Colors.blue;
        break;
      case ItemType.activity:
        icon = Icons.local_activity;
        iconColor = Colors.orange;
        break;
      case ItemType.note:
        icon = Icons.note;
        iconColor = Colors.green;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Item content
          Expanded(
            child: Card(
              child: InkWell(
                onTap: () => _showEditItemDialog(item),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 12),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 12),
                                    Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditItemDialog(item);
                              } else if (value == 'delete') {
                                _confirmDeleteItem(item);
                              }
                            },
                          ),
                        ],
                      ),
                      if (item.scheduledTime != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${dateFormat.format(item.scheduledTime!)} at ${timeFormat.format(item.scheduledTime!)}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (item.location != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.location!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (item.description != null &&
                          item.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    ItemType itemType = ItemType.activity;
    DateTime? scheduledTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ItemType>(
                  value: itemType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ItemType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.value.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => itemType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g., Visit Eiffel Tower',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (Optional)',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Scheduled Time (Optional)'),
                  subtitle: Text(scheduledTime != null
                      ? DateFormat('MMM dd, yyyy - h:mm a').format(scheduledTime!)
                      : 'Not set'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _itinerary!.startDate,
                      firstDate: _itinerary!.startDate,
                      lastDate: _itinerary!.endDate,
                    );
                    if (date != null && context.mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setDialogState(() {
                          scheduledTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                await _itineraryService.addItem(
                  itineraryId: widget.itineraryId,
                  itemType: itemType,
                  title: titleController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  location: locationController.text.isEmpty
                      ? null
                      : locationController.text,
                  scheduledTime: scheduledTime,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item added!')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(ItineraryItem item) {
    final titleController = TextEditingController(text: item.title);
    final descriptionController =
        TextEditingController(text: item.description ?? '');
    final locationController =
        TextEditingController(text: item.location ?? '');
    DateTime? scheduledTime = item.scheduledTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Scheduled Time'),
                  subtitle: Text(scheduledTime != null
                      ? DateFormat('MMM dd, yyyy - h:mm a').format(scheduledTime!)
                      : 'Not set'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: scheduledTime ?? _itinerary!.startDate,
                      firstDate: _itinerary!.startDate,
                      lastDate: _itinerary!.endDate,
                    );
                    if (date != null && context.mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: scheduledTime != null
                            ? TimeOfDay.fromDateTime(scheduledTime!)
                            : TimeOfDay.now(),
                      );
                      if (time != null) {
                        setDialogState(() {
                          scheduledTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await _itineraryService.updateItem(
                  id: item.id!,
                  itineraryId: widget.itineraryId,
                  title: titleController.text,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  location: locationController.text.isEmpty
                      ? null
                      : locationController.text,
                  scheduledTime: scheduledTime,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item updated!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteItem(ItineraryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _itineraryService.deleteItem(item.id!, widget.itineraryId);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item deleted')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
