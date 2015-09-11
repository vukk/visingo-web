/*
 *
 *
 * TODO: when adding nodes, calculate approximate positions before adding
 *       maybe by:
 *       if run for each node: take connected node coords, average, run few iterations
 *       if run for all: fix nodes, straighten edges,
 *                       run physics, capture positions, release, show
 * TODO: automatic zooming OUT (only) via animation http://visjs.org/examples/network/other/animationShowcase.html animation fit() (make it a setting though)
 */
var testVisGraphVisualizer = (function (vis, _, parser) {
    var my = {},
        network,
        context,
        container,
        canvas,
        entities,
        currentEntityKeys = {nodes: [], edges: []},
        attributes,
        entityDeltas = {nodes: [], edges: []},
        attributeDeltas = [],
        cursor = 0;

    my.destroy = function() {
        // more like a reset than a destroy
        if(network instanceof vis.Network) {
            network.destroy();
            context = undefined;
            canvas = undefined;
            entities = undefined;
            currentEntityKeys = {nodes: [], edges: []};
            attributes = undefined;
            entityDeltas = {nodes: [], edges: []};
            attributeDeltas = [];
            cursor = 0;
        }
    }

    my.initialize = function(visJsContainer, settings) {
        my.destroy();
        container = visJsContainer;

        // entities are visjs network "data"
        entities = {
            nodes: new vis.DataSet([], {queue: true}),
            edges: new vis.DataSet([], {queue: true}),
            // hack, keep flushed duplicates. TODO FIX THIS, FastFwd problematic
            fNodes: new vis.DataSet([], {queue: false}),
            fEdges: new vis.DataSet([], {queue: false})
        };

        // attributes are visjs network "options"
        attributes = {
            autoResize: true,
            physics: {
                barnesHut: {
                    damping: 0.38
                },
                forceAtlas2Based: {
                    //springConstant: 0.02
                },
                maxVelocity: 15,
                solver: 'forceAtlas2Based',
                timestep: 0.25
            },
            nodes: {
                color: {
                    background: "#DCEDC8",
                    border: "#7CB342",
                    highlight: {
                        background: "#F1F8E9",
                        border: "#7CB342"
                    }
                }
            }
        };

        // settings
        if(settings.directed === true)
            _.set(attributes, 'edges.arrows.to.enabled', true);


        // create network
        network = new vis.Network(container, entities, attributes);

        // load initial options
        loadCurrentOptions();

        console.log('Loaded network with default attributes: ', attributes);

        my.network = network; // TODO remove
        my.edges = entities.edges;
        my.nodes = entities.nodes;
        my.entityDeltas = entityDeltas;
        my.attributeDeltas = attributeDeltas;

        canvas    = container.firstChild.firstChild;
        context   = canvas.getContext('2d');
    };

    function loadCurrentOptions() {
        // see https://github.com/almende/vis/blob/955dd25caa276560513c96178a3aad5d313952c6/lib/network/Network.js#L186
        attributes = network.options;
        _.merge(attributes, network.canvas.options);

        var attr = attributes;

        attr.nodes      = network.nodesHandler.options;
        attr.edges      = network.edgesHandler.options;
        attr.layout     = network.layoutEngine.options;
        attr.physics    = network.physics.options;

        /*
        attr.interaction = {};
        _.merge(
            attr.interaction,
            network.selectionHandler.options,
            network.renderer.options
        );

        attr.manipulation = network.manipulation.options;
        */
    }

    function doParsing(set) {
        var toParse;
        if(_.isArray(set)) {
            toParse = set.join(' ');
        }
        else if(_.isString(set)) {
            toParse = set;
        }
        else
            return false;

        //console.log('parsing', toParse);

        return parser.parse(toParse);
    };

    // my.queueAnswerSet()
    //
    my.addAnswerSet = function(set) {
        var ret = my.queueAnswerSet(set);
        my.flushChanges();
        return ret;
    };

    my.queueAnswerSet = function(set) {
        var parsed = doParsing(set);
        //console.log('parsed', parsed);
        if(parsed === false) return false;

        // entities
        // node and edge

        var nodesToRem = _.difference(currentEntityKeys.nodes, Object.keys(parsed.nodes));
        var edgesToRem = _.difference(currentEntityKeys.edges, Object.keys(parsed.edges));
        var nodesToAdd = _.difference(Object.keys(parsed.nodes), currentEntityKeys.nodes);
        var edgesToAdd = _.difference(Object.keys(parsed.edges), currentEntityKeys.edges);

        entityDeltas.nodes[cursor] = {};
        entityDeltas.edges[cursor] = {};

        _.map(edgesToRem, function(key) {
            entityDeltas.edges[cursor][key] = entities.fEdges.get(key);
        });
        _.map(nodesToRem, function(key) {
            entityDeltas.nodes[cursor][key] = entities.fNodes.get(key);
        });
        entities.edges.remove(edgesToRem); entities.fEdges.remove(edgesToRem);
        entities.nodes.remove(nodesToRem); entities.fNodes.remove(nodesToRem);

        // add
        _.map(nodesToAdd, function(key) {
            // by default show id as label, but don't override if label set
            if(typeof parsed.nodes[key].label === 'undefined')
                parsed.nodes[key].label = String(parsed.nodes[key].id);

            entities.nodes.add(parsed.nodes[key]);
            entities.fNodes.add(parsed.nodes[key]);
            entityDeltas.nodes[cursor][key] = null;
        });
        _.map(edgesToAdd, function(key) {
            entities.edges.add(parsed.edges[key]);
            entities.fEdges.add(parsed.edges[key]);
            entityDeltas.edges[cursor][key] = null;
        });

        // entities that stay, (nodes & edges to update)
        var nodesToUpd = _.difference(currentEntityKeys.nodes, nodesToRem);
        var edgesToUpd = _.difference(currentEntityKeys.edges, edgesToRem);

        /*
        currentEntityKeys.nodes =
            _.union(nodesToAdd, _.difference(currentEntityKeys.nodes, nodesToRem));
        currentEntityKeys.edges =
            _.union(edgesToAdd, _.difference(currentEntityKeys.edges, edgesToRem));
        */
        currentEntityKeys.nodes = _.union(nodesToAdd, nodesToUpd);
        currentEntityKeys.edges = _.union(edgesToAdd, edgesToUpd);


        _.map(nodesToUpd, function(key) {
            //console.log('nodeupdate', parsed.nodes[key]);
            var ow = _.overwritten(
              parsed.nodes[key],
              entities.fNodes.get(key)
            );
            if(typeof ow !== 'undefined')
              entityDeltas.nodes[cursor][key] = ow;
            entities.nodes.update(parsed.nodes[key]);
            entities.fNodes.update(parsed.nodes[key]);
        });
        _.map(edgesToUpd, function(key) {
            //console.log('edgeupdate', parsed.edges[key]);
            var ow = _.overwritten(
              parsed.edges[key],
              entities.fEdges.get(key)
            );
            if(typeof ow !== 'undefined')
              entityDeltas.edges[cursor][key] = ow;
            entities.edges.update(parsed.edges[key]);
            entities.fEdges.update(parsed.edges[key]);
        });

        // attributes

        // remove nodes and edges, we don't want them in attributes
        // and they are no longer needed
        delete parsed.nodes;
        delete parsed.edges;
        // rename entity attributes when needed
        // global node and edge attributes, nodeDefaults -> nodes, edgeDefaults -> edges
        parsed.nodes = parsed.nodeDefaults;
        parsed.edges = parsed.edgeDefaults;
        delete parsed.nodeDefaults;
        delete parsed.edgeDefaults;

        //console.log('parsed', parsed);
        //console.log(JSON.stringify(parsed), JSON.stringify(attributes));

        // _.deepDiff(current, new) gives only what's different in new compared to current
        // _.deepDiff is defined as a mixin in lodash-import.html
        var attributeChanges = _.deepDiff(attributes, parsed);
        attributeDeltas[cursor] = _.overwritten(attributeChanges, attributes);


        //console.log('current: ', attributes);
        //console.log('parsed: ', parsed, ' changes: ', attributeChanges);
        // TODO: queue changes, execute upon my.flushChanges()
        network.setOptions(attributeChanges);

        cursor += 1;
        return true;
    };

    my.undo = function() {
        if(cursor === 0) return false;
        cursor -= 1;

        var nodesToRem = Object.keys(_.pick(entityDeltas.nodes[cursor], _.isNull));
        var edgesToRem = Object.keys(_.pick(entityDeltas.edges[cursor], _.isNull));
        entities.edges.remove(edgesToRem);
        entities.nodes.remove(nodesToRem);

        var nodesToUpdObjs = _.pick(
          entityDeltas.nodes[cursor],
          function(x) { return !_.isNull(x) }
        );
        var edgesToUpdObjs = _.pick(
          entityDeltas.edges[cursor],
          function(x) { return !_.isNull(x) }
        );

        currentEntityKeys.nodes = _.union(
          Object.keys(nodesToUpdObjs),
          _.difference(currentEntityKeys.nodes, nodesToRem)
        );
        currentEntityKeys.edges = _.union(
          Object.keys(edgesToUpdObjs),
          _.difference(currentEntityKeys.edges, edgesToRem)
        );

        console.log('undoing update:', nodesToUpdObjs, edgesToUpdObjs);
        _.forOwn(nodesToUpdObjs, function(value, key) {
            value['id'] = key;
            console.log('node', 'key', key, 'value', value);
            entities.nodes.update(value);
        });
        _.forOwn(edgesToUpdObjs, function(value, key) {
            value['id'] = key;
            console.log('edge', 'key', key, 'value', value);
            entities.edges.update(value);
        });

        network.setOptions(attributeDeltas[cursor]);
        my.flushChanges();
        return true;
    };

    my.flushChanges = function() {
        // Flush changes to screen
        entities.nodes.flush();
        entities.edges.flush();
    };

    my.fitNetwork = function(duration) {
        if(typeof duration === 'undefined')
            duration = 3000;

        var options = {
            duration: duration, // ms
            easingFunction: 'easeInOutCubic'
        };
        network.fit({animation:options});
    };

  return my;
}(vis, _, visingo.parsers.answersettermsToVisjs));
