# =========================================
# Autor: Esteve Lladó (Fundació Bit), 2016
# =========================================


(($) ->    

    # Función para extraer las marcas de la REST y renderizar resultados
    # ------------------------------------------------------------------
    getBrands = () ->
        brand_list = []
        request = "/rest_utils/brands"
        $.ajax({url: request, type: "GET"})
        .done (data) ->

            # Chequeamos si la REST ha devuelto un error
            # -------------------------------------------
            if data.error?
                $('#statusPanel').html MyApp.templates.commonsRestApiError {message: data.error}
            else
                data.results.forEach (brand) ->
                    brand_list.push({'value': brand, 'name': brand.charAt(0).toUpperCase() + brand.slice(1)})
                html_content = MyApp.templates.selectBrands {entries: brand_list, all_brands: true, label: true }
                $('#form-group-brands').html html_content
    
    # Función para extraer datos de la REST y renderizar resultados
    # ---------------------------------------------------------------
    getSeriesDataAndRenderChart = (year, brand) ->
        request = "/rest_tweets_retweets/series/year/#{year}/brand/#{brand}"
        $.ajax({url: request, type: "GET"})
        .done (data) ->

            # Chequeamos si la REST ha devuelto un error
            # -------------------------------------------
            if data.error?
                $('#statusPanel').html MyApp.templates.commonsRestApiError {message: data.error}
            else
                # =================
                # Petición REST OK
                # =================
                $('#statusPanel').html ''

                # Reset the canvas. If not several canvas could appear supperposed
                $('#seriesChart').remove()
                $('#chartContainer').append('<canvas id="seriesChart" width="70%" height="20px"></canvas>')
                

                brandMessage = if brand == '--all--' 
                then 'totes les marques' else brand.charAt(0).toUpperCase() + brand.slice(1)

                ctx = document.getElementById('seriesChart').getContext('2d')
                

                seriesChart = new Chart(ctx, {
                    type: 'line'
                    data: data.results
                    options:
                        responsive: true
                        title:
                            display: true
                            text: "Sèrie temporal de " + brandMessage + " per a l'any " + year
                        tooltips:
                            mode: 'x'
                            intersect: true
                            hover:
                                mode: 'nearest'
                                intersect: true
                        scaleShowValues: true
                        scales:
                            xAxes:[{
                                gridLines:
                                    display: false
                                ticks:
                                    source: 'labels'
                                    autoSkip: false
                                scaleLabel:
                                    display: true
                                    labelString: 'Data'
                            } ]
                            yAxes: [ {
                                gridLines:
                                    display: false
                                scaleLabel:
                                    display: true
                                    labelString: 'Freqüència'
                            } ]
                })

                $('#seriesChart').show()


    # Fijamos evento sobre botón de Buscar
    # -------------------------------------
    $('#searchButton').click (event) ->

        # ---------------------------------
        # Recogemos valores del formulario
        # ---------------------------------
        brand = $('#searchForm select[name="brand"]').val()
        year = $('#searchForm select[name="year"]').val()

        # =========================
        # Validación de formulario
        # =========================
        if year is null
            setTimeout ( -> $('#statusPanel').html '' ), 1000
            $('#statusPanel').html MyApp.templates.commonsFormValidation {form_field: 'any'}
        else if brand is null
            setTimeout ( -> $('#statusPanel').html '' ), 1000
            $('#statusPanel').html MyApp.templates.commonsFormValidation {form_field: 'marca'}
        else
            # ==============
            # Validación OK
            # ==============

            # controlamos visibilidad de elementos
            # -------------------------------------
            # Reset the canvas. If not several canvas could appear supperposed
            $('#seriesChart').remove()
            $('#chartContainer').append('<canvas id="seriesChart" width="70%" height="20px"></canvas>')

            $('#statusPanel').html '<br><br><br><p align="center"><img src="/img/loading_icon.gif">&nbsp;&nbsp;Carregant...</p>'

            # Petición REST
            # --------------
            getSeriesDataAndRenderChart year, brand

        return false


    # Ocultaciones al inicio
    # -----------------------
    getBrands()
    $('#statusPanel').html ''
    # Reset the canvas. If not several canvas could appear supperposed
    $('#seriesChart').remove()
    $('#chartContainer').append('<canvas id="seriesChart" width="70%" height="20px"></canvas>')

) jQuery