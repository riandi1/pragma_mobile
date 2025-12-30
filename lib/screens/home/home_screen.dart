import 'package:flutter/material.dart';
import '../../core/api/cat_api.dart';
import '../../core/models/cat_breed.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CatBreed> _allBreeds = [];
  List<CatBreed> _filteredBreeds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBreeds();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBreeds() async {
    try {
      final breeds = await CatApi.getBreeds();
      setState(() {
        _allBreeds = breeds;
        _filteredBreeds = breeds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Manejar error aquí si es necesario
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() {
        _filteredBreeds = _allBreeds;
      });
      return;
    }

    setState(() {
      _filteredBreeds = _allBreeds.where((cat) {
        return cat.name.toLowerCase().contains(query) ||
               cat.temperament.toLowerCase().contains(query) ||
               cat.origin.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
  }

  // Método para determinar el número de columnas según el ancho de pantalla
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width > 900) {
      return 4; // Para pantallas grandes
    } else if (width > 600) {
      return 3; // Para tablets
    } else if (width > 400) {
      return 2; // Para pantallas móviles medianas
    } else {
      return 1; // Para pantallas móviles pequeñas
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF0B8F7A);
    final crossAxisCount = _getCrossAxisCount(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.pets, color: accent),
            SizedBox(width: 8),
            Text('Cat Breeds', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de búsqueda funcional
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Buscar razas',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(color: Colors.black87),
                        cursorColor: accent,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                        onPressed: _clearSearch,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Contador de resultados
            if (_searchController.text.isNotEmpty && !_isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      '${_filteredBreeds.length} resultado${_filteredBreeds.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (crossAxisCount > 1)
                      Text(
                        '$crossAxisCount columnas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            // GridView responsive
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    )
                  : _filteredBreeds.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty
                                    ? 'No hay razas disponibles'
                                    : 'No se encontraron resultados para "${_searchController.text}"',
                                style: const TextStyle(color: Colors.grey, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.zero,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: _getChildAspectRatio(context),
                          ),
                          itemCount: _filteredBreeds.length,
                          itemBuilder: (context, index) {
                            final cat = _filteredBreeds[index];
                            return _buildCatCard(cat, context, accent, crossAxisCount);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para calcular el aspect ratio según el número de columnas
  double _getChildAspectRatio(BuildContext context) {
    final crossAxisCount = _getCrossAxisCount(context);
    
    if (crossAxisCount == 1) {
      return 1.6; // Más rectangular para 1 columna
    } else if (crossAxisCount == 2) {
      return 0.9; // Más cuadrado para 2 columnas
    } else {
      return 0.8; // Más cuadrado para 3+ columnas
    }
  }

  Widget _buildCatCard(CatBreed cat, BuildContext context, Color accent, int crossAxisCount) {
    final isSingleColumn = crossAxisCount == 1;
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, '/detail', arguments: cat),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del gato
            Expanded(
              flex: isSingleColumn ? 3 : 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: cat.imageUrl.isNotEmpty
                    ? Image.network(
                        cat.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[100],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: accent,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[100],
                          child: Center(
                            child: Icon(
                              Icons.pets,
                              size: isSingleColumn ? 40 : 30,
                              color: accent.withAlpha((0.5 * 255).round()),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Icon(
                            Icons.pets,
                            size: isSingleColumn ? 40 : 30,
                            color: accent.withAlpha((0.5 * 255).round()),
                          ),
                        ),
                      ),
              ),
            ),
            // Contenido del card
            Expanded(
              flex: isSingleColumn ? 2 : 1,
              child: Padding(
                padding: EdgeInsets.all(isSingleColumn ? 16 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nombre
                    Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: isSingleColumn ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Temperamento (solo en 1 columna o si hay espacio)
                    if (isSingleColumn) ...[
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          cat.temperament,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    
                    // Información en fila
                    Row(
                      children: [
                        // Origen
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, size: 12, color: Colors.black54),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    cat.origin,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Esperanza de vida
                        if (!isSingleColumn) const SizedBox(width: 8),
                        if (!isSingleColumn)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time, size: 12, color: Colors.black54),
                                const SizedBox(width: 4),
                                Text(
                                  cat.lifeSpan,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    // Esperanza de vida (solo en 1 columna)
                    if (isSingleColumn) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accent.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time, size: 12, color: Colors.black54),
                            const SizedBox(width: 4),
                            Text(
                              '${cat.lifeSpan} years',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}