//NOEL P. ANDO//
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'pokemon.dart';

void main() {
  runApp(const CustomPokemonApp());
}

class CustomPokemonApp extends StatelessWidget {
  const CustomPokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokedex Terminal',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0A0F1D),
        fontFamily: 'Courier', // Lain nga font style para unique
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00E5FF),
          brightness: Brightness.dark,
        ),
      ),
      home: const CustomSearchPage(),
    );
  }
}

class CustomSearchPage extends StatefulWidget {
  const CustomSearchPage({super.key});

  @override
  State<CustomSearchPage> createState() => _CustomSearchPageState();
}

class _CustomSearchPageState extends State<CustomSearchPage> {
  final TextEditingController _controller = TextEditingController(text: 'timburr');
  
  Pokemon? _pokemon;
  bool _isLoading = false;
  String? _errorMessage;

  static const cyan = Color(0xFF00E5FF);
  static const darkBg = Color(0xFF111827);
  static const cardBg = Color(0xFF1F2937);
  static const lightText = Color(0xFFF3F4F6);
  static const grayText = Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    _fetchPokemon(_controller.text);
  }

  Future<void> _fetchPokemon(String query) async {
    final formattedName = query.trim().toLowerCase();
    if (formattedName.isEmpty) {
      setState(() {
        _errorMessage = 'Palihog pagbutang og Pokémon name.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$formattedName');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          _pokemon = Pokemon.fromJson(data);
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Wala makit-i ang Pokémon "$formattedName". Susiha ang spelling.';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Napakyas sa pag-load (Error: ${response.statusCode}).';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Susiha ang imong internet connection.';
        _isLoading = false;
      });
    }
  }

  String pretty(String value) => value
      .split('-')
      .map((s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}')
      .join(' ');

  Color typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fighting': return const Color(0xFFEF4444);
      case 'bug': return const Color(0xFF84CC16);
      case 'fire': return const Color(0xFFF97316);
      case 'water': return const Color(0xFF3B82F6);
      case 'grass': return const Color(0xFF10B981);
      case 'electric': return const Color(0xFFEAB308);
      case 'poison': return const Color(0xFFA855F7);
      case 'psychic': return const Color(0xFFEC4899);
      case 'ice': return const Color(0xFF06B6D4);
      default: return cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: darkBg,
        elevation: 4,
        shadowColor: cyan.withValues(alpha: 0.3),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.terminal, color: cyan, size: 24),
            SizedBox(width: 8),
            Text(
              'POKEMON DATABASE',
              style: TextStyle(
                fontSize: 13,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
                color: lightText,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 500;

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 24,
                vertical: 20,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    // Search Bar Area
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            enabled: !_isLoading,
                            style: const TextStyle(color: lightText, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Searching Pokemon...',
                              labelStyle: const TextStyle(color: grayText, fontSize: 12),
                              filled: true,
                              fillColor: cardBg,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: cyan, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: cyan.withValues(alpha: 0.4)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: cyan, width: 2),
                              ),
                              prefixIcon: const Icon(Icons.search_rounded, color: cyan),
                            ),
                            onSubmitted: (val) => _fetchPokemon(val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cyan,
                            foregroundColor: darkBg,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _isLoading ? null : () => _fetchPokemon(_controller.text),
                          child: const Icon(Icons.arrow_forward_rounded, size: 22),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // States
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: cyan),
                      )
                    else if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF451A03),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: lightText, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_pokemon != null)
                      _buildCyberCard(_pokemon!),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCyberCard(Pokemon pokemon) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cyan, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: cyan.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(pokemon),
            const SizedBox(height: 12),
            _buildImageView(pokemon),
            const SizedBox(height: 12),
            _buildSpecsRow(pokemon),
            const SizedBox(height: 16),
            _buildAbilitiesSection(pokemon),
            const Divider(color: Colors.white24, height: 24),
            _buildMovesSection(pokemon),
            const SizedBox(height: 12),
            _buildCardFooter(pokemon),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(Pokemon pokemon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt, color: cyan, size: 18),
            const SizedBox(width: 4),
            Text(
              pretty(pokemon.name),
              style: const TextStyle(
                color: lightText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: cyan.withValues(alpha: 0.5)),
          ),
          child: Text(
            '#${pokemon.id.toString().padLeft(3, '0')}',
            style: const TextStyle(
              color: cyan,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageView(Pokemon pokemon) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Stack(
        children: [
          Center(
            child: pokemon.spriteUrl.isEmpty
                ? const Icon(Icons.image_not_supported, size: 80, color: grayText)
                : Image.network(
                    pokemon.spriteUrl,
                    fit: BoxFit.contain,
                    height: 170,
                    width: 170,
                    errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 80, color: grayText),
                  ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Wrap(
              spacing: 4,
              children: pokemon.types.map((t) => _typeChip(t)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: typeColor(type),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildSpecsRow(Pokemon pokemon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _specBadge(Icons.height, 'HEIGHT', '${(pokemon.height / 10).toStringAsFixed(1)}m'),
        _specBadge(Icons.fitness_center, 'WEIGHT', '${(pokemon.weight / 10).toStringAsFixed(1)}kg'),
        _specBadge(Icons.star_border, 'BASE XP', '${pokemon.baseExperience}'),
      ],
    );
  }

  Widget _specBadge(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: cyan),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: grayText, fontSize: 8)),
              Text(value, style: const TextStyle(color: lightText, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbilitiesSection(Pokemon pokemon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ABILITIES',
          style: TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        ...pokemon.abilities.map((ability) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(ability.isHidden ? Icons.lock : Icons.radio_button_checked, size: 12, color: grayText),
                  const SizedBox(width: 6),
                  Text(
                    pretty(ability.name),
                    style: const TextStyle(color: lightText, fontSize: 12),
                  ),
                  if (ability.isHidden) ...[
                    const SizedBox(width: 6),
                    const Text('(Hidden)', style: TextStyle(color: Colors.amber, fontSize: 10)),
                  ]
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildMovesSection(Pokemon pokemon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'KNOWN MOVES',
              style: TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            Text('${pokemon.moves.length} moves', style: const TextStyle(color: grayText, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.builder(
            itemCount: pokemon.moves.length,
            itemBuilder: (context, index) {
              final move = pokemon.moves[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.chevron_right, size: 14, color: cyan),
                    const SizedBox(width: 4),
                    Text(
                      pretty(move.name),
                      style: const TextStyle(color: lightText, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCardFooter(Pokemon pokemon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Held Items: ${pokemon.heldItems.isEmpty ? "None" : pokemon.heldItems.length}',
          style: const TextStyle(color: grayText, fontSize: 10),
        ),
        const Text(
          'SYSTEM v2.0',
          style: TextStyle(color: cyan, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}