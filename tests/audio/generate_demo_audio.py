"""Rebuild the three owned synthetic WAV tracks and their technical case.

Python standard library only. No voices, network, external samples or TTS.
All tracks use the same 12-second / 22050 Hz timeline; peaks come from PCM.
"""
from pathlib import Path
import json
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[2]
RATE, SECONDS = 22050, 12


def pulse(t, start, frequency, length=0.18):
    local = t - start
    if not 0 <= local < length:
        return 0.0
    return math.sin(math.pi * local / length) ** 2 * math.sin(2 * math.pi * frequency * local)


def main():
    destination = ROOT / "assets/audio/demo"
    destination.mkdir(parents=True, exist_ok=True)
    rng = random.Random(901)
    samples = {name: [] for name in ("original", "ambiente", "voces")}
    for index in range(RATE * SECONDS):
        t = index / RATE
        ambient = sum(pulse(t, at, 420, 0.22) for at in (4.5, 5.2, 5.9))
        marker = pulse(t, 8.5, 660, 0.4) + pulse(t, 9.3, 990, 0.4)
        hum = math.sin(2 * math.pi * 110 * t)
        noise = rng.uniform(-1, 1)
        values = {"original": 0.12 * hum + 0.12 * noise + 0.13 * ambient + 0.12 * marker,
                  "ambiente": 0.025 * hum + 0.48 * ambient,
                  "voces": 0.015 * hum + 0.40 * marker}
        for name, value in values.items():
            samples[name].append(round(max(-0.95, min(0.95, value)) * 32767))
    for name, values in samples.items():
        with wave.open(str(destination / f"demo_{name}.wav"), "wb") as output:
            output.setparams((1, 2, RATE, len(values), "NONE", "not compressed"))
            output.writeframes(struct.pack(f"<{len(values)}h", *values))
    waveform = [round(max(abs(v) for v in samples["original"][i * RATE // 10:(i + 1) * RATE // 10]) / 32767, 4) for i in range(120)]
    recording = {
        "recording_id": "aud_recording_01", "title": "Ensayo de línea · señal técnica",
        "description": "Grabación sintética de doce segundos, fuera de campaña. Los filtros son mezclas preparadas de la misma línea temporal; Voces contiene un marcador electrónico, sin voz humana.",
        "case_id": "audio_analysis_demo", "unlocked_by": {"op": "equals", "target": "recording_unlocked", "value": True},
        "duration": 12, "waveform": waveform,
        "variants": [{"filter_id": name, "label": label, "audio_path": f"res://assets/audio/demo/demo_{name}.wav", "available": True} for name, label in (("original", "Original"), ("ambiente", "Ambiente"), ("voces", "Voces · marcador sintético"))],
        "segments": [
            {"segment_id": "aud_s01", "start_time": 0, "end_time": 4, "title": "Inicio de línea · 00:00–00:04", "accessible_information": {"original": "Un zumbido estable y ruido uniforme abren la señal.", "ambiente": "Fondo estable, sin patrón de pulsos en este intervalo.", "voces": "Fondo tenue. No hay palabras ni marcador en este intervalo."}},
            {"segment_id": "aud_s02", "start_time": 4, "end_time": 8, "title": "Intervalo central · 00:04–00:08", "accessible_information": {"original": "Tres pulsos breves quedan parcialmente cubiertos por el ruido.", "ambiente": "Se distinguen tres pulsos de igual altura, separados regularmente. El texto describe la misma señal disponible al oído.", "voces": "Fondo tenue, sin marcador electrónico en este intervalo."}},
            {"segment_id": "aud_s03", "start_time": 8, "end_time": 12, "title": "Cierre de señal · 00:08–00:12", "accessible_information": {"original": "Dos tonos electrónicos están mezclados con el zumbido y el ruido.", "ambiente": "Fondo estable; no aparece aquí el patrón triple central.", "voces": "Marcador sintético de prueba: dos tonos, primero grave y después agudo. No representa voz ni palabras de una persona."}}
        ]
    }
    data = {
        "schema_version": 3, "case_id": "audio_analysis_demo", "content_version": "audio-1.0",
        "title": "Ensayo de análisis · fuera de campaña", "initial_node": "aud_intro",
        "characters": [{"id": "aud_operator", "display_name": "Operador · simulación"}],
        "variables": {"recording_unlocked": {"type": "bool"}}, "initial_state": {"variables": {"recording_unlocked": False}, "evidence": []},
        "evidence_catalog": ["aud_reference", "aud_pulses", "aud_marker"], "event_catalog": ["aud_observation"], "endings": ["aud_complete", "aud_partial"],
        "nodes": [
            {"id": "aud_intro", "type": "dialogue", "speaker_id": "aud_operator", "text": "Comprobación técnica fuera de campaña. Puedo habilitar una señal sintética y registrar el patrón de referencia: tres pulsos. No hay personas ni una emergencia real en esta grabación.", "options": [{"id": "aud_unlock", "text": "Habilitar la grabación y registrar el patrón de referencia.", "next": "aud_hub", "effects": [{"op": "set", "target": "recording_unlocked", "value": True}, {"op": "add_to_set", "target": "evidence", "value": "aud_reference"}]}]},
            {"id": "aud_hub", "type": "dialogue", "speaker_id": "aud_operator", "text": "La grabación está disponible en Audio. Examine los intervalos y filtros, consulte la información textual equivalente y registre las observaciones justificadas. Después puede contrastar una pista sonora con la referencia en Expedientes.", "options": [{"id": "aud_finish", "text": "Cerrar la prueba con el contraste registrado.", "next": "aud_end_complete", "visible_when": {"op": "contains", "target": "executed_actions", "value": "aud_d01"}}, {"id": "aud_close", "text": "Cerrar la demostración sin completar el contraste.", "next": "aud_end_partial"}]},
            {"id": "aud_end_complete", "type": "ending", "ending_id": "aud_complete", "text": "Ensayo cerrado: la referencia coincide con el patrón observado. Las fuentes permanecen consultables."},
            {"id": "aud_end_partial", "type": "ending", "ending_id": "aud_partial", "text": "Ensayo cerrado con las observaciones obtenidas hasta este momento."}
        ],
        "investigation": {
            "evidence": [
                {"id": "aud_reference", "title": "Referencia del ensayo", "description": "La referencia técnica declara tres pulsos iguales en el intervalo central. Debe contrastarse con una observación de la señal.", "category": "document", "source": "Comunicación técnica · referencia del ensayo", "importance": "essential", "order": 1},
                {"id": "aud_pulses", "title": "Tres pulsos ambientales", "description": "En el intervalo central de la mezcla Ambiente se distingue un patrón regular de tres pulsos. El examen sonoro y su descripción textual corresponden a la misma fuente.", "category": "audio", "source": "Ensayo de línea · intervalo 00:04–00:08 · Ambiente", "importance": "essential", "order": 2},
                {"id": "aud_marker", "title": "Marcador electrónico ascendente", "description": "La mezcla Voces presenta dos tonos de prueba, grave y agudo, en el cierre. Es una observación opcional; no es una voz humana ni una anomalía oficial.", "category": "audio", "source": "Ensayo de línea · intervalo 00:08–00:12 · Voces sintéticas", "importance": "optional", "order": 3}
            ], "actions": [],
            "deductions": [{"id": "aud_d01", "title": "Patrón de referencia confirmado", "description": "La referencia de tres pulsos coincide con el patrón examinado en Ambiente. Esta conclusión solo certifica el ensayo técnico.", "required_evidence": ["aud_reference", "aud_pulses"], "result_type": "VALID", "repeatable": False, "effects": [], "narrative_feedback": "La observación sonora coincide con la referencia. Puede cerrar el ensayo desde Llamadas."}]
        },
        "audio_analysis": {"recordings": [recording], "discovery_rules": [
            {"id": "aud_rule_pulses", "recording_id": "aud_recording_01", "evidence_id": "aud_pulses", "segment_id": "aud_s02", "filter_id": "ambiente", "min_listen_seconds": 3, "once_only": True, "event_id": "aud_observation"},
            {"id": "aud_rule_marker", "recording_id": "aud_recording_01", "evidence_id": "aud_marker", "segment_id": "aud_s03", "filter_id": "voces", "min_listen_seconds": 3, "once_only": True}
        ]}
    }
    target = ROOT / "data/audio/audio_analysis_demo.json"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("Generated three synchronized 12-second mono PCM WAVs and technical case.")


if __name__ == "__main__":
    main()
