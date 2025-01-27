import { Controller } from '@hotwired/stimulus';
import React, { lazy, Suspense, FunctionComponent, StrictMode } from 'react';
import { render, unmountComponentAtNode } from 'react-dom';
import invariant from 'tiny-invariant';

type Props = Record<string, unknown>;
type Loader = () => Promise<{ default: FunctionComponent<Props> }>;
const componentsRegistry = new Map<string, FunctionComponent<Props>>();

export function registerComponents(components: Record<string, Loader>): void {
  for (const [className, loader] of Object.entries(components)) {
    componentsRegistry.set(className, LoadableComponent(loader));
  }
}

// Initialize React components when their markup appears into the DOM.
//
// Example:
//   <div data-controller="react" data-react-component-value="ComboMultiple" data-react-props-value="{}"></div>
//
export class ReactController extends Controller {
  static values = {
    component: String,
    props: Object
  };

  declare readonly componentValue: string;
  declare readonly propsValue: Props;

  connect(): void {
    this.mountComponent(this.element as HTMLElement);
  }

  disconnect(): void {
    unmountComponentAtNode(this.element as HTMLElement);
  }

  private mountComponent(node: HTMLElement): void {
    const componentName = this.componentValue;
    const props = this.propsValue;
    const Component = this.getComponent(componentName);

    invariant(
      Component,
      `Cannot find a React component with class "${componentName}"`
    );
    render(
      <StrictMode>
        <Component {...props} />
      </StrictMode>,
      node
    );
  }

  private getComponent(componentName: string): FunctionComponent<Props> | null {
    return componentsRegistry.get(componentName) ?? null;
  }
}

const Spinner = () => <div className="spinner left" />;

function LoadableComponent(loader: Loader): FunctionComponent<Props> {
  const LazyComponent = lazy(loader);
  const Component: FunctionComponent<Props> = (props: Props) => (
    <Suspense fallback={<Spinner />}>
      <LazyComponent {...props} />
    </Suspense>
  );
  return Component;
}
