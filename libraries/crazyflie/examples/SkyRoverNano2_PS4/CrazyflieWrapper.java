import se.bitcraze.crazyflie.lib.toc.*;
import se.bitcraze.crazyflie.lib.param.*;
import se.bitcraze.crazyflie.lib.crazyflie.*;
import se.bitcraze.crazyflie.lib.crtp.*;
import se.bitcraze.crazyflie.lib.usb.*;
import se.bitcraze.crazyflie.lib.log.*;
import se.bitcraze.crazyflie.lib.crazyradio.*;

import se.bitcraze.crazyflie.lib.crazyflie.Crazyflie.State;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;



public class CrazyflieWrapper {

    private Crazyflie mCrazyflie;
    private boolean mSetupFinished;
    private Param mParam;

    public CrazyflieWrapper() {
        mCrazyflie = new Crazyflie(new RadioDriver(new UsbLinkJava()));
    }

    public void connect() {
        List<ConnectionData> foundCrazyflies = scan();
        if (foundCrazyflies.isEmpty()) {
            System.err.println("No crazyflies found.");
            return;
        }

        mCrazyflie.addConnectionListener(new ConnectionAdapter() {

            public void setupFinished(String connectionInfo) {
                System.out.println("SETUP FINISHED: " + connectionInfo);
                mSetupFinished = true; //<>//
            }

        });
        mCrazyflie.connect(foundCrazyflies.get(0));
    }

    private List<ConnectionData> scan() {
        RadioDriver radioDriver = new RadioDriver(new UsbLinkJava());
        List<ConnectionData> foundCrazyflies = radioDriver.scanInterface();
        radioDriver.disconnect();
        return foundCrazyflies;
    }

    public void disconnect() {
        mCrazyflie.disconnect();
    }

    public void sendCommandPacket(float roll, float pitch, float yaw, char thrust) {
        // TODO: if(mCrazyflie.isConnected()) {
        if(mCrazyflie.getState().ordinal() >= State.CONNECTED.ordinal()) {
            mCrazyflie.sendPacket(new CommanderPacket(roll, pitch, yaw, thrust));
        } else {
            System.err.println("No crazyflie connected.");
        }
    }

    public void setParameterValue(String parameterName, Number value) {
        if(mSetupFinished) {
            mParam = mCrazyflie.getParam();
            mParam.setValue(parameterName, value);
        } else {
            System.out.println("Setup not finished yet.");
        }
    }

    public Number getParameterValue(String parameterName) {
        if(mSetupFinished) {
            mParam = mCrazyflie.getParam();
            mParam.requestParamUpdate(parameterName);
            // TODO: return mParam.getValue(parameterName);
            String[] paraName = parameterName.split("\\.");
            
            //System.out.println( mParam.getToc().getTocSize() );
            
            //System.out.println(paraName[0]);
            //System.out.println(paraName[1]);
            //System.out.println("end");
            //System.out.println(mParam.getValuesMap());
        
            return mParam.getValuesMap().get(paraName[0]).get(paraName[1]); //<>//
        } else {
            System.out.println("Setup not finished yet.");
            return null;
        }
    }

    public Map<String, Map<String, Number>> getParameterList() {
        if(mSetupFinished) {
            mParam = mCrazyflie.getParam();
            mParam.requestUpdateOfAllParams();
            return mParam.getValuesMap();
        } else {
            System.out.println("Setup not finished yet.");
            return new HashMap<String, Map<String, Number>>();
        }
    }

    public void addLogConfig(LogConfig logConfig) {

    }

    public void startLogConfig(LogConfig logConfig) {

    }

    public void stopLogConfig(LogConfig logConfig) {

    }

    public void deleteLogConfig(LogConfig logConfig) {

    }

    public boolean isConnected() { return mSetupFinished; }
  
    //TODO: getLogConfig data
    //TODO: get Console data

    //TODO: connectionStateChangedListener?

}
