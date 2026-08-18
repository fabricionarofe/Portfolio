<?php
/**
 * Classe responsável pela lógica do widget e shortcode.
 */

class Cotacao_Widget {

    /**
     * Inicializa os hooks do WordPress.
     */
    public function init() {
        // Registra o shortcode [cotacao_moeda]
        add_shortcode( 'cotacao_moeda', array( $this, 'render_shortcode' ) );
        
        // Adiciona estilos inline no head para manter o plugin independente
        add_action( 'wp_head', array( $this, 'add_inline_styles' ) );
    }

    /**
     * Renderiza o HTML do shortcode.
     * 
     * @param array $atts Atributos do shortcode.
     * @return string HTML renderizado.
     */
    public function render_shortcode( $atts ) {
        // Simulação de chamada a uma API externa (Mock Data)
        $dados_api = $this->fetch_mock_cotacoes();

        // Extrai as moedas desejadas ou usa padrão (USD)
        $atributos = shortcode_atts( array(
            'moeda' => 'USD',
        ), $atts );

        $moeda_alvo = strtoupper($atributos['moeda']);
        $valor = isset($dados_api[$moeda_alvo]) ? $dados_api[$moeda_alvo] : 'Indisponível';

        // Constroi o output (Clean Code)
        ob_start();
        ?>
        <div class="cotacao-widget-container">
            <div class="cotacao-header">
                <h4>Cotação Atual</h4>
            </div>
            <div class="cotacao-body">
                <span class="cotacao-moeda"><?php echo esc_html( $moeda_alvo ); ?>/BRL</span>
                <span class="cotacao-valor">R$ <?php echo esc_html( number_format((float)$valor, 2, ',', '.') ); ?></span>
            </div>
            <div class="cotacao-footer">
                <small>Atualizado em tempo real (Mock)</small>
            </div>
        </div>
        <?php
        return ob_get_clean();
    }

    /**
     * Simula o retorno de uma API financeira.
     * Em um cenário real, usaria wp_remote_get() com transient caching.
     * 
     * @return array
     */
    private function fetch_mock_cotacoes() {
        return array(
            'USD' => 5.23,
            'EUR' => 5.75,
            'GBP' => 6.50
        );
    }

    /**
     * Adiciona estilos inline para o widget.
     */
    public function add_inline_styles() {
        ?>
        <style>
            .cotacao-widget-container {
                border: 1px solid #ddd;
                border-radius: 8px;
                max-width: 250px;
                font-family: Arial, sans-serif;
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                background-color: #fff;
            }
            .cotacao-header {
                background-color: #f8f9fa;
                padding: 10px;
                border-bottom: 1px solid #ddd;
                border-top-left-radius: 8px;
                border-top-right-radius: 8px;
            }
            .cotacao-header h4 {
                margin: 0;
                color: #333;
                font-size: 16px;
            }
            .cotacao-body {
                padding: 15px 10px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            .cotacao-moeda {
                font-weight: bold;
                color: #555;
            }
            .cotacao-valor {
                font-size: 18px;
                color: #28a745;
                font-weight: bold;
            }
            .cotacao-footer {
                padding: 8px 10px;
                background-color: #f8f9fa;
                border-top: 1px solid #ddd;
                border-bottom-left-radius: 8px;
                border-bottom-right-radius: 8px;
                text-align: center;
                color: #777;
            }
        </style>
        <?php
    }
}
