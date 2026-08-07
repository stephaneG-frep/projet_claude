import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../features/exercises/domain/exercise.dart';
import '../../features/glossary/domain/glossary_term.dart';
import '../../features/lessons/domain/module.dart';
import '../../features/missions/domain/mission.dart';
import '../../features/projects/domain/project.dart';
import '../../features/reference/domain/reference_entry.dart';

/// Charge le contenu pédagogique hors ligne depuis `assets/content/`
/// (section 40). Le contenu est écrit sous forme de données structurées,
/// jamais codé en dur dans les widgets (section 41).
class ContentRepository {
  List<LearningModule>? _modules;
  List<Exercise>? _exercises;
  List<Mission>? _missions;
  List<Project>? _projects;
  List<ReferenceEntry>? _reference;
  List<GlossaryTerm>? _glossary;

  Future<List<dynamic>> _loadJsonList(String path) async {
    final raw = await rootBundle.loadString(path);
    return jsonDecode(raw) as List<dynamic>;
  }

  Future<List<LearningModule>> loadModules() async {
    if (_modules != null) return _modules!;
    final raw = await _loadJsonList('assets/content/modules/modules.json');
    final modules = raw
        .map((m) => LearningModule.fromJson(m as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
    _modules = modules;
    return modules;
  }

  Future<List<Exercise>> loadExercises() async {
    if (_exercises != null) return _exercises!;
    final raw =
        await _loadJsonList('assets/content/exercises/exercises.json');
    final list =
        raw.map((e) => Exercise.fromJson(e as Map<String, dynamic>)).toList();
    _exercises = list;
    return list;
  }

  Future<List<Mission>> loadMissions() async {
    if (_missions != null) return _missions!;
    final raw = await _loadJsonList('assets/content/missions/missions.json');
    final list = raw
        .map((m) => Mission.fromJson(m as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
    _missions = list;
    return list;
  }

  Future<List<Project>> loadProjects() async {
    if (_projects != null) return _projects!;
    final raw = await _loadJsonList('assets/content/projects/projects.json');
    final list = raw
        .map((p) => Project.fromJson(p as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
    _projects = list;
    return list;
  }

  Future<List<ReferenceEntry>> loadReference() async {
    if (_reference != null) return _reference!;
    final raw = await _loadJsonList('assets/content/reference/reference.json');
    final list = raw
        .map((r) => ReferenceEntry.fromJson(r as Map<String, dynamic>))
        .toList();
    _reference = list;
    return list;
  }

  Future<List<GlossaryTerm>> loadGlossary() async {
    if (_glossary != null) return _glossary!;
    final raw = await _loadJsonList('assets/content/glossary/glossary.json');
    final list = raw
        .map((g) => GlossaryTerm.fromJson(g as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.term.compareTo(b.term));
    _glossary = list;
    return list;
  }
}
