import 'package:flutter/material.dart';

class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data: Replace with your actual data source
    final clients = [
      {
        'name': 'Alice',
        'image': 'https://i.pravatar.cc/150?img=1',
        'lastMessage': 'Hello, I need info!',
        'unreadCount': 2,
      },
      {
        'name': 'Bob',
        'image': 'https://i.pravatar.cc/150?img=2',
        'lastMessage': 'Thank you!',
        'unreadCount': 0,
      },
      {
        'name': 'Charlie',
        'image': 'https://i.pravatar.cc/150?img=3',
        'lastMessage': 'Can we schedule a call?',
        'unreadCount': 1,
      },
    ];

    return Scaffold(
      body: ListView.separated(
        itemCount: clients.length,
        separatorBuilder:
            (context, index) =>
                const Divider(indent: 72, endIndent: 16, height: 0),
        itemBuilder: (context, index) {
          final client = clients[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(client['image'] as String),
            ),
            title: Text(
              client['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              client['lastMessage'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color:
                    (client['unreadCount'] as int) > 0
                        ? Colors.black
                        : Colors.grey[600],
                fontWeight:
                    (client['unreadCount'] as int) > 0
                        ? FontWeight.w600
                        : FontWeight.normal,
              ),
            ),
            trailing:
                (client['unreadCount'] as int) > 0
                    ? Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        client['unreadCount'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : null,
            onTap: () {
              // TODO: Navigate to chat detail screen
            },
          );
        },
      ),
    );
  }
}
