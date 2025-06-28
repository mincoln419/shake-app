// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vo_todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
      id: json['id'] as int,
      title: json['title'] as String,
      dueDtm: DateTime.parse(json['dueDtm'] as String),
      modifyTime: json['modifyTime'] == null
          ? null
          : DateTime.parse(json['modifyTime'] as String),
      status: $enumDecodeNullable(_$TodoStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'modifyTime': instance.modifyTime?.toIso8601String(),
      'dueDtm': instance.dueDtm.toIso8601String(),
      'status': _$TodoStatusEnumMap[instance.status]!,
    };

const _$TodoStatusEnumMap = {
  TodoStatus.incomplete: 'incomplete',
  TodoStatus.ongoing: 'ongoing',
  TodoStatus.complete: 'complete',
};
