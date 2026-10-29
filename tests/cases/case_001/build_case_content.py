"""Authoring helper: preserve the approved Markdown dialogue verbatim.

Not a game dependency. Run from the repository root with Python 3.
Conditions/effects below translate the explicit tables of PROMPT 02.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DESIGN = (ROOT / 'docs/cases/CASE_001_DESIGN.md').read_text(encoding='utf-8')
OUT = ROOT / 'data/cases/case_001'

def nid(n): return f'c001_n{n:02}'
def eid(n): return f'c001_e{n:02}'
def qid(n): return f'c001_q{n:02}'
def eq(t, v): return {'op': 'equals', 'target': t, 'value': v}
def all_of(*c): return {'op': 'all', 'conditions': list(c)}
def any_of(*c): return {'op': 'any', 'conditions': list(c)}
def has(n): return {'op': 'contains', 'target': 'evidence', 'value': eid(n)}
def ded(n): return {'op': 'contains', 'target': 'executed_actions', 'value': qid(n)}
def put(t, v): return {'op': 'set', 'target': t, 'value': v}
def mark(v): return {'op': 'mark_once', 'value': v}
def gain(*ns): return [{'op': 'add_to_set', 'target': 'evidence', 'value': eid(n)} for n in ns]
def text_part(c, t): return {'condition': c, 'text': t}
ALWAYS = {'op': 'always'}
PENDING = eq('resultado', 'pendiente')
TOOLS = all_of(PENDING, any_of(eq('etapa', 'C'), eq('etapa', 'D'), eq('etapa', 'E')))
COOPERATES = all_of({'op': 'at_least', 'target': 'confianza', 'value': 1}, {'op': 'at_most', 'target': 'estres', 'value': 1})
PATIO = all_of(eq('r1_assignment', 'c001_i02'), eq('r1_status', 'BUSY'))

def build():
    chunks = re.split(r'^### N(\d{2}) — .*$', DESIGN, flags=re.M)
    nodes = []
    for k in range(1, len(chunks), 2):
        n = int(chunks[k])
        body = chunks[k+1]
        header = re.search(rf'^### N{n:02} — (P\d\d)', DESIGN, re.M)
        texts = re.findall(r'\*\*Texto[^\n]*?\*\*\s*«([^»]+)»', body)
        assert texts, n
        node = {'id': nid(n), 'type': 'dialogue', 'speaker_id': 'c001_' + header[1].lower(), 'text': texts[0], 'options': []}
        for row in re.findall(r'^\| O\d\d .*$', body, re.M):
            cols = [v.strip() for v in row.strip('|').split('|')]
            oi = int(cols[0][1:])
            dest = re.search(r'N(\d{2})', cols[-1])
            option = {'id': f'{nid(n)}_o{oi:02}', 'text': cols[1], 'next': nid(int(dest[1])) if dest else 'c001_end_route'}
            node['options'].append(option)
        if n == 10:
            node['text_variants'] = [text_part(eq('etapa', 'E'), texts[1])]
        if n in (25, 30):
            node['text_variants'] = [text_part(eq('plan', 'refugio'), texts[0]), text_part(all_of(eq('plan', 'servicio'), ded(2)), texts[1] if n == 25 else texts[2]), text_part(eq('plan', 'servicio'), texts[2] if n == 25 else texts[1]), text_part(eq('plan', 'pasillo'), texts[3])]
        if n == 36:
            node['text'] = texts[1]
            node['text_variants'] = [text_part(ded(3), texts[0])]
        nodes.append(node)
    assert len(nodes) == 38
    by = {int(node['id'][-2:]): node for node in nodes}
    def opt(n, o): return by[n]['options'][o-1]
    entries = {4:[1],8:[2],11:[4],12:[3],14:[5],15:[9],19:[6],20:[4,6,7],21:[8],22:[10]}
    for n, evidence in entries.items(): by[n]['entry_effects'] = gain(*evidence)
    for n, panel in [(13,'audio'),(16,'map'),(17,'evidence')]: by[n]['panel_id'] = panel
    by[16]['text_rows'] = [text_part(eq('r1_status','AVAILABLE'),'R1 disponible. Seleccione un destino para inspección exterior'),text_part(all_of(eq('r1_status','ASSIGNED'),eq('r1_assignment','c001_i01')),'R1 asignada al frente. Pulse «Recibir parte»'),text_part(all_of(eq('r1_status','ASSIGNED'),eq('r1_assignment','c001_i02')),'R1 asignada al patio. Pulse «Recibir parte»'),text_part(all_of(eq('r1_status','BUSY'),eq('r1_assignment','c001_i01')),'Parte del frente recibido. Puede reubicar R1 al patio'),text_part(PATIO,'Acceso posterior comprobado. R1 mantiene posición exterior')]
    for n, o in [(1,1),(2,1)]: opt(n,o)['effects'] = [put('comunicacion','activa')]
    for n in (3,21):
        for o, delta in [(1,1),(2,-1)]:
            opt(n,o)['effects'] = [{'op':'add_clamped','target':'confianza','value':delta}, {'op':'add_clamped','target':'estres','value':-delta}]
    opt(6,1)['effects'] = [put('etapa','B')]
    opt(8,1)['effects'] = [put('etapa','C')]
    opt(18,1)['effects'] = [put('confianza',1),put('estres',0)]
    opt(10,8)['visible_when'] = {'op':'once_not_applied','value':'c001_n18_o01'}
    opt(10,9).update(visible_when=eq('etapa','C'),enabled_when=all_of(ded(1),has(6)),disabled_reason='Relacione el testimonio con la ficha y reciba un parte exterior',effects=[put('etapa','D'),mark('c001_k01')])
    opt(10,10)['visible_when'] = eq('etapa','E')
    opt(10,11)['visible_when'] = ded(4)
    opt(22,1)['effects'] = [put('etapa','E')]
    opt(24,2)['effects'] = [put('plan','refugio')]
    opt(24,3).update(visible_when=has(4),enabled_when=PATIO,disabled_reason='Falta comprobar el acceso posterior con R1',effects=[put('plan','servicio')])
    opt(24,4)['text'] += ' · riesgo conocido: humo'
    opt(25,1).update(next='c001_resolver_a',enabled_when=all_of(PENDING,eq('etapa','E'),eq('comunicacion','activa'),has(6),any_of(eq('plan','refugio'),eq('plan','pasillo'),all_of(eq('plan','servicio'),PATIO))),disabled_reason='La instrucción no se puede transmitir con este estado. Revise el expediente y el despacho')
    opt(25,2)['effects'] = [put('plan','ninguno')]
    opt(26,1)['effects'] = [put('plan','ninguno')]
    opt(26,2)['effects'] = [put('plan','pasillo')]
    by[25]['text_rows'] = [text_part(ded(2),'Amenaza: interpretada'),text_part({'op':'not','condition':ded(2)},'Amenaza: sin deducción confirmada'),text_part(PATIO,'Unidad: patio'),text_part({'op':'not','condition':PATIO},'Unidad: frente'),text_part(COOPERATES,'Clara: cooperando'),text_part({'op':'not','condition':COOPERATES},'Clara: necesita calma'),text_part(all_of(eq('plan','servicio'),{'op':'not','condition':ded(2)}),'La instrucción aún no identifica una puerta concreta. Relacione las fuentes para precisarla')]
    by[37]['text_rows'] = []
    def row(condition, text): by[37]['text_rows'].append(text_part(condition,text))
    for result, label in [('A','Salida comunicada'),('B','Refugio sin confirmación'),('C','Contacto perdido en riesgo')]: row(eq('resultado',result),'Resultado: '+label)
    for condition, yes, no in [(ded(2),'Interpretación del peligro: confirmada','Interpretación del peligro: pendiente'),(has(7),'Acceso posterior: verificado','Acceso posterior: no verificado'),(COOPERATES,'Cooperación al transmitir: suficiente','Cooperación al transmitir: insuficiente'),(ded(3),'N-4: vinculado documentalmente a ECO','N-4: procedencia pendiente'),(ded(4),'Identidad histórica: correspondencia documentada','Identidad histórica: sin contrastar')]:
        row(condition,yes); row({'op':'not','condition':condition},no)
    for condition, message in [(eq('plan','servicio'),'No se eligió una evacuación por servicio'),(ded(2),'Faltó confirmar la interpretación del peligro'),(has(7),'Faltó verificar el acceso posterior'),(COOPERATES,'Faltó recuperar la cooperación')]: row(all_of(eq('resultado','B'),{'op':'not','condition':condition}),message)
    row(eq('resultado','C'),'Se indicó abrir al pasillo pese al humo, con confianza agotada y estrés alto')
    dialogue_count = sum(len(node['options']) for node in nodes)
    assert dialogue_count == 57, dialogue_count
    def transition(id, condition, yes, no): return {'id':id,'type':'transition','condition':condition,'next':yes,'fallback_next':no}
    favorable = all_of(eq('plan','servicio'),ded(2),PATIO,COOPERATES)
    adverse = all_of(eq('plan','pasillo'),eq('confianza',0),eq('estres',2))
    nodes += [transition('c001_resolver_a',favorable,'c001_commit_a','c001_resolver_c'),transition('c001_resolver_c',adverse,'c001_commit_c','c001_commit_b')]
    for result, start in [('A',27),('B',30),('C',33)]:
        nodes.append({'id':'c001_commit_'+result.lower(),'type':'transition','next':nid(start),'entry_effects':[put('resultado',result),put('etapa','F'),put('comunicacion','cerrada' if result=='A' else 'interrumpida'),mark('c001_k02')]})
        nodes.append({'id':'c001_end_'+result.lower(),'type':'ending','ending_id':'c001_final_'+result.lower(),'text':'Caso 001 · atención cerrada. Puede consultar las fuentes conservadas.'})
    nodes += [transition('c001_end_route',eq('resultado','A'),'c001_end_a','c001_end_route_c'),transition('c001_end_route_c',eq('resultado','C'),'c001_end_c','c001_end_b')]
    variables = {'confianza':{'type':'int','min':0,'max':2},'estres':{'type':'int','min':0,'max':2}}
    initial = {'confianza':1,'estres':1}
    for name, values, value in [('etapa',list('ABCDEF'),'A'),('plan',['ninguno','refugio','servicio','pasillo'],'ninguno'),('comunicacion',['entrante','activa','cerrada','interrumpida'],'entrante'),('resultado',['pendiente','A','B','C'],'pendiente'),('r1_status',['AVAILABLE','ASSIGNED','BUSY','UNAVAILABLE'],'AVAILABLE'),('r1_assignment',['','c001_i01','c001_i02'],''),('frente_status',['REPORTED','ASSIGNED','RESOLVED','CLOSED'],'REPORTED'),('patio_status',['REPORTED','ASSIGNED','RESOLVED','CLOSED'],'REPORTED')]:
        variables[name] = {'type':'string','allowed_values':values}; initial[name] = value
    evidence = []
    sources = {
        1:'Comunicación de la línea dos · Clara Salcedo.',
        2:'Archivo municipal · ficha de clausura del Hotel Mirador.',
        3:'Línea dos · información sonora y testimonio sobre el humo.',
        4:'Hotel Mirador · plano de planta y referencia de la puerta de servicio.',
        5:'Registro histórico de huéspedes · 14/11/1981.',
        6:'R1 · inspección exterior actual del Hotel Mirador.',
        7:'R1 · parte de inspección del patio posterior.',
        8:'Línea dos · lectura del recibo de Clara Salcedo.',
        9:'Archivo de telefonía · anexo del 10/11/1981.',
        10:'Central de comunicaciones · datos de captura de la línea dos.',
    }
    for line in re.findall(r'^\| E\d\d — .*$', DESIGN,re.M):
        c = [v.strip() for v in line.strip('|').split('|')]
        num = int(c[0][1:3]); title = c[0].split(' — ')[1].split(' · ')[0]
        evidence.append({'id':eid(num),'title':title,'description':c[1],'category': 'testimony' if num==1 else ('audio' if num==3 else 'document'),'source':sources[num],'importance':'optional' if num in (5,9) else ('contextual' if num==10 else 'essential'),'order':num})
    assert len(evidence)==10
    deductions=[]
    for line in re.findall(r'^\| Q\d\d — .*$',DESIGN,re.M):
        c=[v.strip() for v in line.strip('|').split('|')]; num=int(c[0][1:3]); explanation=re.search('«([^»]+)»',c[2])[1]
        deductions.append({'id':qid(num),'title':c[0].split(' — ')[1],'description':'Seleccione las fuentes que sostienen esta hipótesis.','required_evidence':[eid(int(v)) for v in re.findall(r'E(\d\d)',c[1])],'additional_conditions':TOOLS,'result_type':'VALID','effects':[],'repeatable':False,'narrative_feedback':explanation})
    assert len(deductions)==4
    records=[]
    transcript1=['Clara: «Hotel Mirador… habitación trescientos cuatro». Zumbido de línea.','Tres golpes, alarma grave, tos. Voz lejana: «¡Bomberos! ¡No abra al pasillo!»','Clara: «No puedo salir por ahí». Tos, roce junto al teléfono.']
    transcript2=['Clara: «Clara Salcedo, trescientos cuatro. Catorce de noviembre de mil novecientos ochenta y uno».','Línea con chasquido; sin mensaje secreto ni voz nueva.']
    for num, duration, ranges, texts in [(1,18,[(0,6),(6,14),(14,18)],transcript1),(2,12,[(0,9),(9,12)],transcript2)]:
        rid=f'c001_g{num:02}'
        segments=[]
        for index, (a,b) in enumerate(ranges,1):
            accessible={f:texts[index-1] for f in ['original','voces','ambiente']}
            if num==1 and index==2: accessible['original']='Tres golpes, alarma grave, tos. Voz lejana [poco clara].'
            segments.append({'segment_id':f'{rid}_s{index:02}','start_time':a,'end_time':b,'title':f'Fragmento {index:02}','accessible_information':accessible})
        records.append({'recording_id':rid,'title':'Primer contacto' if num==1 else 'Fecha y cabecera','description':'Grabación de investigación pendiente de producción. Transcripciones aprobadas disponibles; no contiene audio reproducible.','case_id':'c001','unlocked_by':has(2) if num==1 else has(8),'duration':duration,'variants':[{'filter_id':f,'label':label,'audio_path':'','available':False} for f,label in [('original','Original'),('voces','Voz de fondo / voz cercana'),('ambiente','Ambiente')]],'segments':segments,'waveform':[]})
    audio={'recordings':records,'discovery_rules':[{'id':'c001_t05','recording_id':'c001_g01','segment_id':'c001_g01_s02','filter_id':'voces','evidence_id':eid(3),'min_listen_seconds':0,'discovery_mode':'consult','additional_conditions':TOOLS,'once_only':True}]}
    records[1]['capture_information'] = [text_part(has(10),'Cabecera de captura: N-4. No consta como circuito activo')]
    operations={'map_id':'c001_mirador','title':'Hotel Mirador · Frente Costero · plano esquemático','closed_when':{'op':'not','condition':PENDING},'districts':[{'id':'c001_costero','name':'Frente Costero','bounds':[0.02,0.03,0.96,0.94]}],'locations':[],'units':[{'unit_id':'c001_r1','display_name':'R1 · Inés Duarte · rescate exterior','unit_type':'RESCUE','initial_status':'AVAILABLE','status_variable':'r1_status','assignment_variable':'r1_assignment'}],'incidents':[],'event_rules':[]}
    operations['layout_kind'] = 'building'
    for num,title,description,position in [(1,'Mirador · Paseo del Faro, 18','Vestíbulo clausurado. Inspección exterior; no entrar en la estructura insegura.',[0.30,0.35]),(2,'Patio posterior del Mirador','Acceso exterior por comprobar. No certifica una salida de la habitación hasta contrastar el plano y el parte.',[0.70,0.70])]:
        operations['locations'].append({'id':f'c001_l{num:02}','name':title,'district_id':'c001_costero','description':description,'position':position,'visible_when':has(2),'information':[text_part(has(6),'Sin humo actual ni personas visibles. Vestíbulo inseguro.'),text_part(has(7),'Escalera y descansillo posterior comprobados desde zona segura.')]})
        operations['incidents'].append({'id':f'c001_i{num:02}','title':'Inspeccionar frente' if num==1 else 'Comprobar patio posterior','description':description,'location_id':f'c001_l{num:02}','incident_type':'exterior_inspection','priority':'HIGH','initial_status':'REPORTED','status_variable':'frente_status' if num==1 else 'patio_status','required_unit_types':['RESCUE'],'unlock_conditions':has(2),'activate_conditions':TOOLS,'dispatch_event':'c001_despacho'})
        operations['event_rules'].append({'id':f'c001_u{num:02}','label':'Recibir parte del frente' if num==1 else 'Recibir parte del patio','result_text':by[19 if num==1 else 20]['text'],'stage':'arrive','unit_id':'c001_r1','incident_id':f'c001_i{num:02}','from_unit_status':'ASSIGNED','to_unit_status':'BUSY','from_incident_status':'ASSIGNED','to_incident_status':'ASSIGNED','condition':TOOLS,'effects':[mark(f'c001_u{num:02}')],'from_node':nid(16),'next':nid(19 if num==1 else 20)})
    operations['event_rules'].append({'id':'c001_m05','label':'Reubicar R1 al patio','result_text':'R1 asignada al patio. Reciba el parte cuando esté preparado.','stage':'reposition','unit_id':'c001_r1','incident_id':'c001_i01','target_incident_id':'c001_i02','from_unit_status':'BUSY','to_unit_status':'ASSIGNED','from_incident_status':'ASSIGNED','to_incident_status':'CLOSED','condition':TOOLS,'effects':[],'from_node':nid(16)})
    content={'schema_version':4,'case_id':'c001','content_version':'c001-1.0','title':'Caso 001 · La habitación 304','initial_node':nid(1),'characters':[{'id':f'c001_p{n:02}','display_name':name} for n,name in enumerate(['Sistema','El Operador','Clara Salcedo','Elena Vargas','Inés Duarte · R1'])],'variables':variables,'initial_state':{'variables':initial,'evidence':[]},'evidence_catalog':[eid(n) for n in range(1,11)],'event_catalog':['c001_despacho'],'endings':['c001_final_a','c001_final_b','c001_final_c'],'nodes':nodes,'investigation':{'evidence':evidence,'deductions':deductions,'actions':[]},'audio_analysis':audio,'operations':operations}
    content['connection_action'] = 'c001_answer'
    content['investigation']['actions'] = [{'id':'c001_answer','title':'Responder comunicación','internal':True,'condition':eq('comunicacion','entrante'),'effects':[put('comunicacion','activa')]}]
    OUT.mkdir(parents=True,exist_ok=True)
    (OUT/'case_001.json').write_text(json.dumps(content,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    voice_manifest=[]
    for node in nodes:
        if node['type']!='dialogue': continue
        voice_manifest.append({'line_id':node['id']+'_line','node_id':node['id'],'speaker_id':node['speaker_id'],'text':node['text'],'status':'pending_09b'})
        for i,v in enumerate(node.get('text_variants',[]),1): voice_manifest.append({'line_id':node['id']+f'_variant_{i:02}','node_id':node['id'],'speaker_id':node['speaker_id'],'text':v['text'],'status':'pending_09b'})
    (OUT/'voice_inventory.json').write_text(json.dumps(voice_manifest,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    print(f'{len(nodes)} total nodes; 38 dialogue nodes; {dialogue_count} choices; {len(voice_manifest)} future lines')

if __name__=='__main__': build()
