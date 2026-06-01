import 'package:flutter/material.dart';

class ChecklistItem {
  final String id;
  final String nome;
  final String descricao;
  final IconData icon;

  const ChecklistItem({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.icon,
  });
}

const kChecklist = [
  ChecklistItem(
    id: 'bombas',
    nome: 'Bombas',
    descricao: 'Estado dos bicos e travas',
    icon: Icons.local_gas_station,
  ),
  ChecklistItem(
    id: 'sinalizacao',
    nome: 'Sinalização',
    descricao: 'Painéis, placas e faixada da bandeira',
    icon: Icons.signpost,
  ),
  ChecklistItem(
    id: 'limpeza',
    nome: 'Limpeza',
    descricao: 'Pista, banheiros e loja',
    icon: Icons.cleaning_services,
  ),
  ChecklistItem(
    id: 'estoque',
    nome: 'Estoque de material',
    descricao: 'Materiais de trade presentes no posto',
    icon: Icons.inventory_2,
  ),
  ChecklistItem(
    id: 'seguranca',
    nome: 'Segurança',
    descricao: 'EPIs, extintores, sinalização de emergência',
    icon: Icons.security,
  ),
  ChecklistItem(
    id: 'atendimento',
    nome: 'Atendimento',
    descricao: 'Uniforme e postura dos frentistas',
    icon: Icons.people,
  ),
];
