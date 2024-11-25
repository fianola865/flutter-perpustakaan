import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'insert.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  _BookListPageState createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  List<Map<String, dynamic>> buku = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await Supabase.instance.client.from('buku').select();
      setState(() {
        buku = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching buku: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteBook(int id) async {
    await Supabase.instance.client.from('buku').delete().eq('id', id);
    fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Buku',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white,),
            onPressed: fetchBooks,
          )
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buku.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada buku tersedia',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: buku.length,
                  itemBuilder: (context, index) {
                    final book = buku[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book['judul'] ?? 'No Title',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book['penulis'] ?? 'No Author',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book['deskripsi'] ?? 'No Description',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blueAccent),
                                  onPressed: () {
                                    // Aksi edit di sini
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Hapus Buku'),
                                          content: const Text(
                                              'Apakah Anda yakin ingin menghapus buku ini?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Batal'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteBook(book['id']);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Hapus'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman untuk menambah buku baru
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBookPage(),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}