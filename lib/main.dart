import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/member_repository.dart';
import 'data/repositories/berita_repository.dart';
import 'data/repositories/kegiatan_repository.dart';
import 'data/repositories/rapat_repository.dart';
import 'data/repositories/absensi_repository.dart';
import 'data/repositories/poin_repository.dart';
import 'data/repositories/uang_khas_repository.dart';
import 'data/repositories/inbox_repository.dart';
import 'data/repositories/or_repository.dart';
import 'data/repositories/periode_repository.dart';

const bool useApiBackend = false;

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserRepository>(
          create: (_) => useApiBackend ? ApiUserRepository() : DummyUserRepository(),
        ),
        ChangeNotifierProvider<MemberRepository>(
          create: (_) => useApiBackend ? ApiMemberRepository() : DummyMemberRepository(),
        ),
        ChangeNotifierProvider<BeritaRepository>(
          create: (_) => useApiBackend ? ApiBeritaRepository() : DummyBeritaRepository(),
        ),
        ChangeNotifierProvider<KegiatanRepository>(
          create: (_) => useApiBackend ? ApiKegiatanRepository() : DummyKegiatanRepository(),
        ),
        ChangeNotifierProvider<RapatRepository>(
          create: (_) => useApiBackend ? ApiRapatRepository() : DummyRapatRepository(),
        ),
        ChangeNotifierProvider<AbsensiRepository>(
          create: (_) => useApiBackend ? ApiAbsensiRepository() : DummyAbsensiRepository(),
        ),
        ChangeNotifierProvider<PoinRepository>(
          create: (_) => useApiBackend ? ApiPoinRepository() : DummyPoinRepository(),
        ),
        ChangeNotifierProvider<UangKhasRepository>(
          create: (_) => useApiBackend ? ApiUangKhasRepository() : DummyUangKhasRepository(),
        ),
        ChangeNotifierProvider<InboxRepository>(
          create: (_) => useApiBackend ? ApiInboxRepository() : DummyInboxRepository(),
        ),
        ChangeNotifierProvider<ORRepository>(
          create: (_) => useApiBackend ? ApiORRepository() : DummyORRepository(),
        ),
        ChangeNotifierProvider<PeriodeRepository>(
          create: (_) => useApiBackend ? ApiPeriodeRepository() : DummyPeriodeRepository(),
        ),
      ],
      child: const App(),
    ),
  );
}
