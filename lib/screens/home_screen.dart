import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/family_service.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/hero_card.dart';
import '../widgets/planilha_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _mostrarSaldo = true;
  bool _isDarkMode = false; // Estado do Modo Escuro
  DateTime _mesSelecionado = DateTime.now();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _familyId = 'familia_default';
  String _appTitle = 'Meus Gastos';

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    final activeId = await FamilyService().getActiveFamilyId();
    final title = await FamilyService().getAppTitle();
    
    // Carregar a preferência salva do Modo Escuro e dos Termos
    final prefs = await SharedPreferences.getInstance();
    final darkModeSaved = prefs.getBool('is_dark_mode') ?? false;
    final termosAceites = prefs.getBool('terms_accepted') ?? false;

    setState(() {
      _familyId = activeId;
      _appTitle = title;
      _isDarkMode = darkModeSaved;
    });

    // Se ainda não aceitou os termos, exibe o pop-up obrigatório após carregar o ecrã
    if (!termosAceites && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarDialogTermosObrigatorios();
      });
    }
  }

  void _mostrarDialogTermosObrigatorios() {
    bool chegouAoFim = false;
    bool concordou = false;
    final ScrollController scrollController = ScrollController();

    showDialog(
      context: context,
      barrierDismissible: false, // Impede fechar clicando fora
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          // Ouve o scroll para detetar quando o utilizador chega ao fim
          scrollController.addListener(() {
            if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 20) {
              if (!chegouAoFim) {
                setStateDialog(() {
                  chegouAoFim = true;
                });
              }
            }
          });

          return AlertDialog(
            backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF6EE),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              'Termos de Uso e Privacidade',
              style: TextStyle(fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black87),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Por favor, leia atentamente todo o termo abaixo para continuar:',
                    style: TextStyle(fontSize: 12, color: _isDarkMode ? Colors.white70 : Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  // Caixa com scroll contendo os termos
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? Colors.black26 : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Text(
                          '1. ACEITAÇÃO DOS TERMOS\n'
                          'Ao aceder ou utilizar a aplicação Gasto Familiar, concorda em cumprir estes Termos de Uso, bem como a nossa Política de Privacidade.\n\n'
                          '2. REGISTO E CONTA\n'
                          'Para utilizar as funcionalidades de sincronização financeira, é necessário efetuar autenticação via Google. O utilizador é inteiramente responsável por manter a confidencialidade das informações da sua conta e grupo familiar.\n\n'
                          '3. USO ACEITÁVEL\n'
                          'A aplicação destina-se exclusivamente ao controlo financeiro pessoal e familiar. Compromete-se a não utilizar a plataforma para quaisquer fins ilícitos, fraudulentos ou não autorizados.\n\n'
                          '4. PRIVACIDADE E DADOS\n'
                          'Os seus dados financeiros são armazenados de forma segura e encriptada através dos serviços do Firebase. Não partilhamos as suas informações financeiras com terceiros.\n\n'
                          '5. MODIFICAÇÕES E DISPONIBILIDADE\n'
                          'Reservamo-nos o direito de modificar, suspender ou encerrar a aplicação ou os seus recursos a qualquer momento, sem aviso prévio. Obrigado por utilizar o Gasto Familiar.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.5,
                            color: _isDarkMode ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Aviso visual se ainda não rolou até ao fim
                  if (!chegouAoFim)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.arrow_downward, size: 14, color: Colors.orange),
                        SizedBox(width: 4),
                        Text(
                          'Role até ao final para poder aceitar',
                          style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  // Checkbox só fica ativo após rolar até ao fim
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFA8E6CF),
                    checkColor: const Color(0xFF2C3E50),
                    enabled: chegouAoFim, // Bloqueado até chegar ao fim
                    title: Text(
                      'Li e concordo com os Termos de Uso e Política de Privacidade',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: chegouAoFim 
                            ? (_isDarkMode ? Colors.white : Colors.black87) 
                            : Colors.grey,
                      ),
                    ),
                    value: concordou,
                    onChanged: chegouAoFim
                        ? (bool? value) {
                            setStateDialog(() {
                              concordou = value ?? false;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: (chegouAoFim && concordou)
                    ? () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('terms_accepted', true);
                        if (context.mounted) Navigator.pop(context);
                      }
                    : null, // Só liberta quando rolar e marcar a caixa
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA8E6CF),
                  disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                ),
                child: const Text('Continuar', style: TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  // Função para alternar e salvar o tema na memória do aparelho
  Future<void> _alternarTema(bool value) async {
    setState(() {
      _isDarkMode = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
  }

  void _mudarMes(int direcao) {
    setState(() {
      _mesSelecionado = DateTime(_mesSelecionado.year, _mesSelecionado.month + direcao, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userPhoto = user?.photoURL;
    final fallbackLetter = user?.email != null && user!.email!.isNotEmpty ? user.email![0].toUpperCase() : 'U';

    // Cores dinâmicas com base no modo escuro
    final Color backgroundColor = _isDarkMode ? const Color(0xFF121212) : const Color(0xFFFAF6EE);
    final Color textColor = _isDarkMode ? Colors.white : const Color(0xFF333333);
    final Color titleColor = _isDarkMode ? Colors.white70 : const Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: CustomDrawer(
        onFamilyChanged: _carregarDadosIniciais,
        isDarkMode: _isDarkMode,
        onThemeChanged: (bool value) {
          _alternarTema(value);
        },
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _mudarMes(1);
          } else if (details.primaryVelocity! > 0) {
            _mudarMes(-1);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(context, userPhoto, fallbackLetter, titleColor, textColor),
                const SizedBox(height: 12),
                _buildBarraNavegacaoMes(textColor),
                const SizedBox(height: 12),
                
                // Efeito de transição suave (AnimatedSwitcher) ao mudar de mês
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.08, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        )),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey<String>('${_mesSelecionado.year}-${_mesSelecionado.month}'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HeroCard(
                        mostrarSaldo: _mostrarSaldo,
                        onToggleVisibility: () => setState(() => _mostrarSaldo = !_mostrarSaldo),
                        mesSelecionado: _mesSelecionado,
                        onTapSaldoFamilia: () => _mostrarDialogAtualizarSaldoFamilia(context),
                        onTapReceitas: () => _mostrarDialogLancarTransacao(context, tipoInicial: 'receita'),
                        onTapGastos: () => _mostrarDialogLancarTransacao(context, tipoInicial: 'despesa'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Transações do Mês',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
                      ),
                      const SizedBox(height: 12),
                      PlanilhaView(
                        familyId: _familyId,
                        mostrarSaldo: _mostrarSaldo,
                        mesSelecionado: _mesSelecionado,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildFloatingButton(context),
    );
  }

  Widget _buildTopBar(BuildContext context, String? photoUrl, String fallbackLetter, Color titleColor, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(builder: (ctx) => IconButton(
          icon: Icon(Icons.menu_rounded, size: 32, color: iconColor),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        )),
        Text(_appTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: titleColor, letterSpacing: -0.5)),
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFFFCBDD),
          backgroundImage: photoUrl != null && photoUrl.isNotEmpty
              ? (photoUrl.startsWith('data:image') ? MemoryImage(base64Decode(photoUrl.split(',')[1])) as ImageProvider : NetworkImage(photoUrl))
              : null,
          child: photoUrl == null || photoUrl.isEmpty ? Text(fallbackLetter, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))) : null,
        ),
      ],
    );
  }

  Widget _buildBarraNavegacaoMes(Color textColor) {
    final meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    String textoMes = '${meses[_mesSelecionado.month - 1]} ${_mesSelecionado.year}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: textColor),
            onPressed: () => _mudarMes(-1),
          ),
          Text(
            textoMes,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: textColor),
            onPressed: () => _mudarMes(1),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogAtualizarSaldoFamilia(BuildContext context) {
    final saldoController = TextEditingController();
    final String chaveMes = '${_mesSelecionado.year}_${_mesSelecionado.month.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF6EE),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Saldo Família (${_mesSelecionado.month}/${_mesSelecionado.year})', style: TextStyle(fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black87)),
        content: TextField(
          controller: saldoController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            labelText: 'Saldo Família deste Mês (R\$)',
            labelStyle: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black54),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final novoSaldo = double.tryParse(saldoController.text.replaceAll(',', '.')) ?? 0.0;
              
              await _db.collection('families').doc(_familyId).set({
                'saldosMensais': {
                  chaveMes: novoSaldo,
                },
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              if (context.mounted) {
                Navigator.pop(context);
              }
              
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
            child: const Text('Salvar', style: TextStyle(color: Color(0xFF2C3E50))),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () => _mostrarDialogLancarTransacao(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD4E6F1),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, color: Color(0xFF2C3E50), size: 22),
            SizedBox(width: 6),
            Text('Lançar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF2C3E50))),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogLancarTransacao(BuildContext context, {String tipoInicial = 'receita'}) async {
    Set<String> categoriasExistentes = {};
    Set<String> descricoesExistentes = {};

    try {
      final txSnapshot = await _db.collection('families').doc(_familyId).collection('transactions').get();
      for (var doc in txSnapshot.docs) {
        final data = doc.data();
        if (data['categoria'] != null) categoriasExistentes.add(data['categoria'].toString());
        if (data['descricao'] != null) descricoesExistentes.add(data['descricao'].toString());
      }
    } catch (_) {}

    final valorController = TextEditingController();
    final descricaoController = TextEditingController();
    final categoriaController = TextEditingController();
    
    String tipoSelecionado = tipoInicial;
    String statusSelecionado = tipoInicial == 'receita' ? 'Recebido' : 'Pago';

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFAF6EE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Nova Transação', style: TextStyle(fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black87)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Receita'),
                      selected: tipoSelecionado == 'receita',
                      selectedColor: const Color(0xFFA8E6CF),
                      onSelected: (selected) {
                        if (!selected) return;
                        setStateDialog(() {
                          tipoSelecionado = 'receita';
                          statusSelecionado = 'Recebido';
                          categoriaController.clear();
                        });
                      },
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('Despesa'),
                      selected: tipoSelecionado == 'despesa',
                      selectedColor: const Color(0xFFFF8B94),
                      onSelected: (selected) {
                        if (!selected) return;
                        setStateDialog(() {
                          tipoSelecionado = 'despesa';
                          statusSelecionado = 'Pago';
                          categoriaController.clear();
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return categoriasExistentes;
                    }
                    return categoriasExistentes.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    categoriaController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (val) => categoriaController.text = val,
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Nome da Coluna / Categoria',
                        labelStyle: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black54),
                        border: const OutlineInputBorder(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return descricoesExistentes;
                    }
                    return descricoesExistentes.where((String option) {
                      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (String selection) {
                    descricaoController.text = selection;
                  },
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onChanged: (val) => descricaoController.text = val,
                      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        labelText: 'Descrição (Ex: Salário / Luz)',
                        labelStyle: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black54),
                        border: const OutlineInputBorder(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: valorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Valor (R\$)',
                    labelStyle: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black54),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: ['Recebido', 'Pago', 'Pendente'].contains(statusSelecionado) 
                      ? statusSelecionado 
                      : (tipoSelecionado == 'receita' ? 'Recebido' : 'Pago'),
                  dropdownColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black54),
                    border: const OutlineInputBorder(),
                  ),
                  items: tipoSelecionado == 'receita'
                      ? const [
                          DropdownMenuItem(value: 'Recebido', child: Text('Recebido')),
                          DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                        ]
                      : const [
                          DropdownMenuItem(value: 'Pago', child: Text('Pago')),
                          DropdownMenuItem(value: 'Pendente', child: Text('Pendente')),
                        ],
                  onChanged: (val) {
                    if (val != null) setStateDialog(() => statusSelecionado = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final valor = double.tryParse(valorController.text.replaceAll(',', '.')) ?? 0.0;
                final descricao = descricaoController.text.trim();
                final categoria = categoriaController.text.trim();

                if (valor > 0) {
                  final transId = _db.collection('families').doc(_familyId).collection('transactions').doc().id;
                  
                  final agora = DateTime.now();
                  final ultimoDiaDoMes = DateTime(_mesSelecionado.year, _mesSelecionado.month + 1, 0).day;
                  final diaApropriado = agora.day > ultimoDiaDoMes ? ultimoDiaDoMes : agora.day;
                  
                  final dataParaSalvar = DateTime(
                    _mesSelecionado.year,
                    _mesSelecionado.month,
                    diaApropriado,
                    agora.hour,
                    agora.minute,
                    agora.second,
                  );

                  await _db.collection('families').doc(_familyId).collection('transactions').doc(transId).set({
                    'categoria': categoria.isNotEmpty ? categoria : (tipoSelecionado == 'receita' ? 'Receita' : 'Despesas'),
                    'descricao': descricao.isNotEmpty ? descricao : (tipoSelecionado == 'receita' ? 'Receita' : 'Despesa'),
                    'valor': valor,
                    'tipo': tipoSelecionado,
                    'status': statusSelecionado,
                    'createdAt': Timestamp.fromDate(dataParaSalvar),
                  });

                  if (context.mounted) Navigator.pop(context);
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4E6F1)),
              child: const Text('Salvar', style: TextStyle(color: Color(0xFF2C3E50))),
            ),
          ],
        ),
      ),
    );
  }
}
