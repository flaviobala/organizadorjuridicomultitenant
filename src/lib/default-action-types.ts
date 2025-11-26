/**
 * Tipos de ação padrão - visíveis para todas as organizações
 * Cada organização pode adicionar seus próprios tipos além destes
 */

export interface DefaultActionType {
  id: string // ID string para diferenciar dos tipos do banco
  name: string
  description: string
  isDefault: true
}

export const DEFAULT_ACTION_TYPES: DefaultActionType[] = [
  {
    id: 'default-acao-civil',
    name: 'Ação Civil Pública',
    description: 'Ação destinada à proteção de interesses difusos e coletivos',
    isDefault: true
  },
  {
    id: 'default-acao-indenizacao',
    name: 'Ação de Indenização',
    description: 'Ação para reparação de danos materiais ou morais',
    isDefault: true
  },
  {
    id: 'default-acao-trabalhista',
    name: 'Ação Trabalhista',
    description: 'Ação relacionada a direitos trabalhistas e relações de trabalho',
    isDefault: true
  },
  {
    id: 'default-acao-penal',
    name: 'Ação Penal',
    description: 'Ação para apuração de crimes e aplicação de penas',
    isDefault: true
  },
  {
    id: 'default-acao-despejo',
    name: 'Ação de Despejo',
    description: 'Ação para retomada de imóvel locado',
    isDefault: true
  },
  {
    id: 'default-acao-cobranca',
    name: 'Ação de Cobrança',
    description: 'Ação para cobrança de dívidas e valores devidos',
    isDefault: true
  },
  {
    id: 'default-acao-execucao',
    name: 'Ação de Execução',
    description: 'Ação para cumprimento forçado de obrigação',
    isDefault: true
  },
  {
    id: 'default-mandado-seguranca',
    name: 'Mandado de Segurança',
    description: 'Ação para proteção de direito líquido e certo contra ato ilegal',
    isDefault: true
  },
  {
    id: 'default-acao-declaratoria',
    name: 'Ação Declaratória',
    description: 'Ação para declaração de existência ou inexistência de relação jurídica',
    isDefault: true
  },
  {
    id: 'default-acao-usucapiao',
    name: 'Ação de Usucapião',
    description: 'Ação para aquisição de propriedade por posse prolongada',
    isDefault: true
  }
]