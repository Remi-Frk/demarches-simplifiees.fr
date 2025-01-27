import React, { useState } from 'react';
import { CursorClickIcon } from '@heroicons/react/outline';
import 'maplibre-gl/dist/maplibre-gl.css';
import '@mapbox/mapbox-gl-draw/dist/mapbox-gl-draw.css';
import type { FeatureCollection } from 'geojson';

import { MapLibre } from '../shared/maplibre/MapLibre';
import { useFeatureCollection } from './hooks';
import { DrawLayer } from './components/DrawLayer';
import { CadastreLayer } from './components/CadastreLayer';
import { AddressInput } from './components/AddressInput';
import { PointInput } from './components/PointInput';
import { ImportFileInput } from './components/ImportFileInput';
import { FlashMessage } from '../shared/FlashMessage';

export default function MapEditor({
  featureCollection: initialFeatureCollection,
  url,
  options,
  preview
}: {
  featureCollection: FeatureCollection;
  url: string;
  preview: boolean;
  options: { layers: string[] };
}) {
  const [cadastreEnabled, setCadastreEnabled] = useState(false);

  const { featureCollection, error, ...actions } = useFeatureCollection(
    initialFeatureCollection,
    { url, enabled: !preview }
  );

  return (
    <>
      <div>
        <p style={{ marginBottom: '20px' }}>
          Besoin d&apos;aide ?&nbsp;
          <a
            href="https://doc.demarches-simplifiees.fr/pour-aller-plus-loin/cartographie"
            target="_blank"
            rel="noreferrer"
          >
            consulter les tutoriels video
          </a>
        </p>
      </div>
      {error && <FlashMessage message={error} level="alert" fixed={true} />}

      <ImportFileInput featureCollection={featureCollection} {...actions} />
      <AddressInput />

      <MapLibre layers={options.layers}>
        <DrawLayer
          featureCollection={featureCollection}
          {...actions}
          enabled={!preview && !cadastreEnabled}
        />
        {options.layers.includes('cadastres') ? (
          <>
            <CadastreLayer
              featureCollection={featureCollection}
              {...actions}
              enabled={!preview && cadastreEnabled}
            />
            <div className="cadastres-selection-control mapboxgl-ctrl-group">
              <button
                type="button"
                onClick={() =>
                  setCadastreEnabled((cadastreEnabled) => !cadastreEnabled)
                }
                title="Sélectionner les parcelles cadastrales"
                className={cadastreEnabled ? 'on' : ''}
              >
                <CursorClickIcon className="icon-size" />
              </button>
            </div>
          </>
        ) : null}
      </MapLibre>
      <PointInput />
    </>
  );
}
