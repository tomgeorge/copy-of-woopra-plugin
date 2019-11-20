package com.redhat.che.workspace.services.telemetry.woopra;

import javax.enterprise.context.Dependent;
import javax.enterprise.inject.Produces;
import org.eclipse.che.incubator.workspace.telemetry.base.AbstractAnalyticsManager;
import org.eclipse.che.incubator.workspace.telemetry.base.BaseConfiguration;

@Dependent
public class MainConfiguration extends BaseConfiguration {
    @Produces
    public AbstractAnalyticsManager analyticsManager() {
      return new AnalyticsManager(apiEndpoint, workspaceId, requestFactory(), new AnalyticsProvider(), new HttpUrlConnectionProvider());
    }
}
